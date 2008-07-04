package virtTripleLoaderInit;

import java.sql.SQLException;
import java.util.Date;

public class Logger {
	public String getTS () {
		Date d = new Date ();
		return d.toString ();
	}
	public void error (SQLException e) {
		System.err.print (getTS());
		System.err.printf (": SQL Error: %s, %s, %d\n",
							e.getSQLState(), e.getMessage(), e.getErrorCode());
	}
	public void error (String error_msg) {
		System.err.println (error_msg);
	}
	public void output (String error_msg) {
		System.out.println (error_msg);
	}
}
