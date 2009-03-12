function link_change (prop)
{
  var a = $('map_link');
  if (a)
    a.href = a.href + '&location-prop=' + escape (prop);
}

function fct_nav_to (url)
{
  document.location = url;
}

function fct_uri_ac_get_matches (ac_ctl)
{
    var val = ac_ctl.value;

    OAT.AJAX.GET("/services/rdf/iriautocomplete.get?uri="+val, false, fct_uri_ac_ajax_handler,{});
}


function fct_uri_ac_ajax_handler (resp)
{
    OAT.Dom.hide ('uri_ac_thr');

    ac.clear_opts();

    var resp_obj = OAT.JSON.parse (resp);

    if (resp_obj.results.length == 0)
	{
	    ac.hide_popup ();
	    return;
	}

    if (resp_obj.restype == "single")
	ac.set_opts (resp_obj.results);
    else 
	ac.set_opts (resp_obj.results[0].concat(resp_obj.results[1]));

    ac.show_popup ();
}

var ac; // Global var ugly as sin OAT.AJAX really needs a way of passing arbitrary obj to callback

function init()
{
    
    ac = new OAT.Autocomplete($('new_uri_txt'), {get_ac_matches: fct_uri_ac_get_matches});
    var tabs = new OAT.Tab ('TAB_CTR', {dockMode: false});

    tabs.add ('TAB_TXT', 'TAB_PAGE_TXT');
    tabs.add ('TAB_URI', 'TAB_PAGE_URI');
    tabs.go (0);

    OAT.MSG.attach ('*', OAT.MSG.AJAX_START, function () { OAT.Dom.show ('uri_ac_thr'); });
    
}

// opts = { loader: function  - function gets called when user hits tab or stops entering text
//          timer_interval: timer interval in msec };

OAT.Autocomplete = function (input, optObj) {
    var self = this;

    this.timer = 0;

    this.options = {
	name:"autocomplete", /* name of input element */
	timer_interval:1000,
	onchange:function() {}
    }
	
    for (var p in optObj) { self.options[p] = optObj[p]; }
    
    this.div = OAT.Dom.create("div",{},"autocomplete");
    
    this.list = OAT.Dom.create("div",
			       {position:"absolute",left:"0px",top:"0px",zIndex:1001},
			       "autocomplete_list");
    
    self.instant = new OAT.Instant(self.list);
    
    this.timer_handler = function (e)
    {
	self.options.get_ac_matches(self);
	ac_timer = 0;
    }

    this.key_handler = function ()
    {
	if (self.timer)
	    window.clearTimeout (self.timer);

	self.value = self.input.value;
	self.timer = window.setTimeout (self.timer_handler, self.options.timer_interval);
	self.value = self.input.value;
    }

    this.blur_handler = function (e) 
    {
	if (self.timer) {
	    window.clearTimeout (self.timer);
	    self.timer = 0;
	}
    }
    
    this.clear_opts = function() 
    {
	OAT.Dom.clear(self.list);
    }
	
    this.addOption = function(name, value) 
    {
	var n = name;
	var v = name;
	if (value) { v = value; }
	var opt = OAT.Dom.create("div",{},"ac_list_option");
	opt.innerHTML = n;
	opt.value = v;
	this.attach(opt);
	self.list.appendChild(opt);
    }

    this.attach = function(option) 
    {
	var ref = function(event) {
	    self.value = option.value;
	    self.input.value = option.value;
	    self.options.onchange(self);
	    self.instant.hide();
            self.input.focus();
	}
	OAT.Dom.attach(option, "click", ref);
    }

    this.set_opts = function (optList)
    {	
	for (var i=0;i<optList.length;i++) {
	    this.addOption(optList[i]);
	}
    }
	
    this.show_popup = function ()
    {
	self.instant.show();
    }

    this.hide_popup = function ()
    {
	self.instant.hide();
    }
	
    self.instant.options.showCallback = function() 
    {
	var coords = OAT.Dom.position(self.input);
	var dims = OAT.Dom.getWH(self.input);
	self.list.style.left = (coords[0]+2) +"px";
	self.list.style.top = (coords[1]+dims[1]+5)+"px";
        self.list.style.width = (dims[0]+"px");
    }

    this.input = input;
    
    OAT.Event.attach (this.input, 'keyup', this.key_handler);
    OAT.Event.attach (this.input, 'blur',  this.blur_handler);
    
    OAT.Dom.append([document.body,self.list]);

}