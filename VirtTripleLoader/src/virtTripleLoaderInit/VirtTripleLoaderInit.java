//
// VirtTripleLoader
//
// Java util to break down WARC files in nice pieces for insertion
//
//WARC-extract:
//for WARC file {
//  for each block {
//    write block in numbered file ldr_block_N.nt
//    INSERT entry for ldr_block to load_list in cluster
//    insert metadata from in mdGraph
//  }
//  write mdGraph into md_N.nt
//  insert md_N.nt into load_list in cluster
//
// Copyright (c) 2008 OpenLink Software
//

package virtTripleLoaderInit;

import it.unimi.dsi.fastutil.io.FastBufferedInputStream;
import it.unimi.dsi.fastutil.io.MeasurableInputStream;
import it.unimi.dsi.law.warc.filters.Filter;
import it.unimi.dsi.law.warc.filters.Filters;
import it.unimi.dsi.law.warc.io.GZWarcRecord;
import it.unimi.dsi.law.warc.io.WarcFilteredIterator;
import it.unimi.dsi.law.warc.io.WarcRecord;
import it.unimi.dsi.law.warc.util.BURL;
import it.unimi.dsi.law.warc.util.WarcHttpResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.*;
import java.util.*;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

import org.openrdf.model.Graph;
import org.openrdf.model.Literal;
import org.openrdf.model.Statement;
import org.openrdf.model.URI;
import org.openrdf.model.ValueFactory;
import org.openrdf.rio.ntriples.NTriplesParser;
import org.openrdf.rio.helpers.RDFHandlerBase;
import org.openrdf.rio.RDFHandlerException;

import org.openrdf.rio.ntriples.NTriplesWriter;

import com.sun.org.apache.xalan.internal.xsltc.cmdline.getopt.GetOpt;

import virtuoso.jdbc3.*;




public class VirtTripleLoaderInit {

	private static final Boolean debugMode = true;
	private static final String myName = "Virtuoso Triple Loader Java";
	private static final Integer myMajorVer = 0;
	private static final Integer myMinorVer = 1;
	private static final Integer myBuild = 0;
	private static final String myCopyright = "Copyright (c) 2008 OpenLink Software";

	private static final String virtConnectUrlDef = "jdbc:virtuoso://neo:1111";
	private static final String virtUserDef = "dba";
	private static final String virtPwdFileDef = "virt_secret";
	private static final String virtPwdDef = "dba";

	private String virtConnectUrl;
	private String virtUser;
	private String virtPwd;
	private String virtPwdFileName;

	// TODO: (ghard) Should be cmdline argument

	private static Connection virtConnection;
	private static PreparedStatement ldAddStmt;

	private static Logger l;
	private GetOpt g;
	private static WarcBlockWriter w;
	private static String curFile;


	private class WarcBlockWriter {
		private Integer fileNo = 0;
		private String fileFormat = "triples_%06d.nt";
		private String curFile;
		private FileOutputStream outStream;
		private byte[] buf = new byte[2048];
		private int bytesRead;
		private int bytesInFile;

		public String write(MeasurableInputStream _block) throws IOException {
			bytesInFile = 0;
			curFile = String.format(fileFormat, fileNo++);
			outStream = new FileOutputStream(curFile);
/*
			while ((bytesRead = _block.read (buf)) != -1) {
				bytesInFile += bytesRead;
				outStream.write(buf);
			}
*/
			int in_url = 0;
			int c = 0;
			while ((c = _block.read()) != -1) {

				bytesInFile ++;
/*			    	if (c == 60) {
				    in_url = 1;
				}
			    	if (c == 62 && in_url==1) {
				    in_url = 0;
				}
				if (in_url==1 && c==32) {
				    c=95;
				}*/
				outStream.write(c);

			}

			l.output("Wrote " + bytesInFile + " in " + curFile);

			outStream.flush();
			outStream.close();
			_block.close();
			return (curFile);

		}
	}

	public VirtTripleLoaderInit() {
		l = new Logger();
		w = new WarcBlockWriter();

		virtConnectUrl = System.getenv("JDBC_DS");
		virtUser = System.getenv("VIRT_USER");
		virtPwdFileName = System.getenv("VIRT_SECRET");

		if (virtConnectUrl == "")
			virtConnectUrl = virtConnectUrlDef;

		try {
			FileInputStream pwdIn = new FileInputStream (virtPwdFileName);
		}
		catch (FileNotFoundException e) {
			l.output("Using default password for virtuoso.");
			virtPwd = virtPwdDef;
		}

		try {
			Class.forName("virtuoso.jdbc3.Driver");

//			 TODO: Use file to store secret. Check file perms and refuse to work if not restrictive enough

			System.out.println (virtConnectUrl);
			System.out.println (virtUser);
			System.out.println (virtPwd);

			virtConnection =
				DriverManager.getConnection(virtConnectUrl,virtUser,virtPwd);

			System.out.println (virtConnection);

			ldAddStmt = virtConnection.prepareStatement("ld_add (?,?)");

		}
		catch (SQLException e) {
			l.error(e);
			l.error("WX0001: Cannot obtain connection to Virtuoso Database. Exiting.");
			System.exit(-1);
		}
		catch (Exception e) {
		    e.printStackTrace();
		    System.exit (-1);
		}
	}

	private static void printUsage () {
		System.out.printf("%s %d.%d.%04d\n", myName, myMajorVer, myMinorVer, myBuild);
		System.out.println(myCopyright);
	}

	public static class TrueFilter extends Filter<BURL> {
		@Override
		public boolean accept(BURL x) {
			return true;
		}

		@Override
		public String toExternalForm() {
			return "true";
		}
	}

	/**
	 * @param args
	 * @throws FileNotFoundException
	 * @author ghard
	 */

	public static void main(String[] args) throws FileNotFoundException {

		VirtTripleLoaderInit vtl = new VirtTripleLoaderInit ();

		if (args.length < 1 || args.length > 2) {
			printUsage();
			l.error("WX0002: Invalid number of arguments. Exiting.");
			System.exit(-1);
		}

		if (args.length == 2) {

		}

		String inFile = args[0];

		l.output("START " + inFile);

		final FastBufferedInputStream in =
			new FastBufferedInputStream(new FileInputStream (new File(inFile)));

		GZWarcRecord record = new GZWarcRecord();
		Filter<WarcRecord> filter = Filters.adaptFilterBURL2WarcRecord (new TrueFilter());
		WarcFilteredIterator it = new WarcFilteredIterator(in, record, filter);

		WarcHttpResponse response = new WarcHttpResponse();

		Graph mdGraph = new org.openrdf.model.impl.GraphImpl();
		String mdGraphURI = "http://challenge.semanticweb.org/2008/metadata";
		ValueFactory vf = mdGraph.getValueFactory();
		String dcNS = "http://purl.org/dc/elements/1.1/";
		DatatypeFactory dtf = null;

		try {
			dtf = DatatypeFactory.newInstance();
		} catch (DatatypeConfigurationException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		GregorianCalendar c = new GregorianCalendar ();

		try {
			int cnt = 0;

//			while (cnt < 1000 && it.hasNext()) {
			while (it.hasNext()) {

				WarcRecord nextRecord = it.next();

				l.output ("cnt " + cnt);
				l.output ("nextRecord " + nextRecord);

				//Get the HttpResponse
				try {
					response.fromWarcRecord (nextRecord);

					if (debugMode) {
						System.out.println("RECORD     : " + String.format("%05d", cnt));
						System.out.println(" subjectUri: " + nextRecord.header.subjectUri);
						System.out.println("contentType: " + nextRecord.header.contentType);
						System.out.println(" dataLength: " + nextRecord.header.dataLength);
						System.out.println("actual data: " + nextRecord.block.length());
						System.out.println("    missing: " +
								(nextRecord.header.dataLength - nextRecord.block.length()) + "b");
					}
					l.output(nextRecord.header.subjectUri.toString());

					URI s, p, o;
					Literal lit;

					s = vf.createURI(nextRecord.header.subjectUri.toString());
					p = vf.createURI(dcNS, "source");
					lit = vf.createLiteral(inFile);

					mdGraph.add(s,p,lit);

					c.setTime(nextRecord.header.creationDate);
					XMLGregorianCalendar xc = dtf.newXMLGregorianCalendar(c);

					p = vf.createURI(dcNS, "date");
					lit = vf.createLiteral(xc);

					mdGraph.add(s,p,lit);

//					p = vf.createURI("http://")

					curFile = w.write(response.contentAsStream());
					l.output ("curFile " + curFile);

					try {
						ldAddStmt.setString(1, curFile);
						ldAddStmt.setString(2, nextRecord.header.subjectUri.toString());
						ResultSet res = ldAddStmt.executeQuery();
					}
					catch (SQLException e) {
						l.error(e);
						l.error("WX0003: Insert to loader table failed. Exiting.");
						System.exit(-1);
					}
				}
				catch (IOException e) {
					e.printStackTrace();
					continue;
				}
				cnt++;
			}
		}


		catch (RuntimeException re) {
			l.error ("WX0004 Unexpected Runtime Error Thrown.");
			l.error (re.toString());
			re.printStackTrace();
			System.exit (-1);
		}
				l.output ("Finish loop ");

		Iterator<Statement> iter = mdGraph.iterator();
		Integer _stmtcnt = 0;
		String mdFile = String.format("%s.md.nt", inFile);

		FileOutputStream outStream = new FileOutputStream(mdFile);
		NTriplesWriter ntw = new NTriplesWriter (outStream);

		ntw.handleNamespace ("dc", dcNS);

		try {
			ntw.startRDF();
			while (iter.hasNext()) {
				Statement _stmt = iter.next();
				ntw.handleStatement(_stmt);
				_stmtcnt++;
			}
			ntw.endRDF();
			outStream.close();
		}
		catch (Exception e) {
			e.printStackTrace();
			System.exit (-1);
		}

		l.output(_stmtcnt + " statements created in metadata graph " + mdGraphURI);
	}
}
