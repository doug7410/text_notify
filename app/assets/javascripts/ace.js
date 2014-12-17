/**
 Required. Ace's Basic File to Initiliaze Different Parts & Some Variables.
*/
if( !('ace' in window) ) window['ace'] = {}
if( !('helper' in window['ace']) ) window['ace'].helper = {}
if( !('options' in window['ace']) ) window['ace'].options = {}
if( !('vars' in window['ace']) ) {
  window['ace'].vars = {
	 'icon'	: ' ace-icon ',
	'.icon'	: '.ace-icon'
  }
}
ace.vars['touch']	= 'ontouchstart' in document.documentElement;


jQuery(function($) {
	//sometimes we try to use 'tap' event instead of 'click' if jquery mobile plugin is available
	ace.click_event = ace.vars['touch'] && $.fn.tap ? 'tap' : 'click';

	//sometimes the only good way to work around browser's pecularities is to detect them using user-agents
	//though it's not accurate
	var agent = navigator.userAgent
	ace.vars['webkit'] = !!agent.match(/AppleWebKit/i)
	ace.vars['safari'] = !!agent.match(/Safari/i) && !agent.match(/Chrome/i);
	ace.vars['android'] = ace.vars['safari'] && !!agent.match(/Android/i)
	ace.vars['ios_safari'] = !!agent.match(/OS ([4-9])(_\d)+ like Mac OS X/i) && !agent.match(/CriOS/i)
	ace.vars['old_ie'] = document.all && !document.addEventListener;
	
	ace.vars['non_auto_fixed'] = ace.vars['android'] || ace.vars['ios_safari'];
	// for android and ios we don't use "top:auto" when breadcrumbs is fixed
	if(ace.vars['non_auto_fixed']) {
		$('body').addClass('mob-safari');
	}

	var docStyle = document.documentElement.style;
	ace.vars['transition'] = 'transition' in docStyle || 'WebkitTransition' in docStyle || 'MozTransition' in docStyle || 'OTransition' in docStyle

	/////////////////////////////

	//a list of available functions with their arguments
	// >>> null means enable
	// >>> false means disable
	// >>> other means function arguments (object)
	var available_functions = {
		'general_vars' : null,//general_vars should come first
		'add_touch_drag' : null,
		'general_things' : null,

		'handle_side_menu' : null,
				
		'sidebar_scrollable' : {
							 //'only_fixed': true, //enable only if sidebar is fixed , for 2nd approach only
							 'scroll_to_active': true, //scroll to selected item? (one time only on page load)
							 'include_shortcuts': true, //true = include shortcut buttons in the scrollbars
							 'include_toggle': false || ace.vars['safari'] || ace.vars['ios_safari'], //true = include toggle button in the scrollbars
							 'smooth_scroll': 200, //> 0 means smooth_scroll, time in ms, used in first approach only, better to be almost the same amount as submenu transition time
							 'outside': false//true && ace.vars['touch'] //used in first approach only, true means the scrollbars should be outside of the sidebar
							},

		'sidebar_hoverable' : {'sub_scroll': false},
									  //automatically move up a submenu, if some part of it goes out of window
									  //set sub_scroll to `true`, to enable native browser scrollbars on submenus when needed (touch devices only)

		'widget_boxes' : null,
		'widget_reload_handler' : null,

		'settings_box' : null,//settings box
		'settings_rtl' : null,
		'settings_skin' : null,

		'enable_searchbox_autocomplete' : null,

		'auto_hide_sidebar' : false,//disable?
		'auto_padding' : false,//disable
		'auto_container' : false//disable
	};

	//enable these functions with related params
	for(var func_name in available_functions) {
		if(!(func_name in ace)) continue;

		var args = available_functions[func_name];
		if(args === false) continue;//don't run this function
		 else if(args === null) args = [jQuery];
		  else if(args instanceof Array) args.unshift(jQuery);//prepend jQuery
		   else args = [jQuery, args];

		ace[func_name].apply(null, args);
	}

})



ace.general_vars = function($) {
	var minimized_menu_class  = 'menu-min';
	var responsive_min_class  = 'responsive-min';
	var horizontal_menu_class = 'h-sidebar';
	
	var sidebar = $('#sidebar').eq(0);
	//differnet mobile menu styles
	ace.vars['mobile_style'] = 1;//default responsive mode with toggle button inside navbar
	if(sidebar.hasClass('responsive') && !$('#menu-toggler').hasClass('navbar-toggle')) ace.vars['mobile_style'] = 2;//toggle button behind sidebar
	 else if(sidebar.hasClass(responsive_min_class)) ace.vars['mobile_style'] = 3;//minimized menu
	  else if(sidebar.hasClass('navbar-collapse')) ace.vars['mobile_style'] = 4;//collapsible (bootstrap style)

	//update some basic variables
	$(window).on('resize.ace.vars' , function(){
		ace.vars['window'] = {width: parseInt($(this).width()), height: parseInt($(this).height())}
		ace.vars['mobile_view'] = ace.vars['mobile_style'] < 4 && ace.helper.mobile_view();
		ace.vars['collapsible'] = !ace.vars['mobile_view'] && ace.helper.collapsible();
		ace.vars['nav_collapse'] = (ace.vars['collapsible'] || ace.vars['mobile_view']) && $('#navbar').hasClass('navbar-collapse');

		var sidebar = $(document.getElementById('sidebar'));
		ace.vars['minimized'] = 
		(!ace.vars['collapsible'] && sidebar.hasClass(minimized_menu_class))
		 ||
		(ace.vars['mobile_style'] == 3 && ace.vars['mobile_view'] && sidebar.hasClass(responsive_min_class))

		ace.vars['horizontal'] = !(ace.vars['mobile_view'] || ace.vars['collapsible']) && sidebar.hasClass(horizontal_menu_class)
	}).triggerHandler('resize.ace.vars');
}

//
ace.general_things = function($) {
	//add scrollbars for user dropdowns
	var has_scroll = !!$.fn.ace_scroll;
	if(has_scroll) $('.dropdown-content').ace_scroll({reset: false, mouseWheelLock: true})
	/**
	//add scrollbars to body
	 if(has_scroll) $('body').ace_scroll({size: ace.helper.winHeight()})
	 $('body').css('position', 'static')
	*/

	//reset scrolls bars on window resize
	$(window).on('resize.reset_scroll', function() {
		if(!has_scroll) return;
		$('.ace-scroll').ace_scroll('reset');
		/**
		 //reset body scrollbars
		 $('body').ace_scroll('update', {size : ace.helper.winHeight()})
		*/
	});
	if(has_scroll) $(document).on('settings.ace.reset_scroll', function(e, name) {
		if(name == 'sidebar_collapsed') $('.ace-scroll').ace_scroll('reset');
	});


	//change a dropdown to "dropup" depending on its position
	$(document).on('click.dropdown.pos', '.dropdown-toggle[data-position="auto"]', function() {
		var offset = $(this).offset();
		var parent = $(this.parentNode);

		if ( parseInt(offset.top + $(this).height()) + 50 
				>
			(ace.helper.scrollTop() + ace.helper.winHeight() - parent.find('.dropdown-menu').eq(0).height()) 
			) parent.addClass('dropup');
		else parent.removeClass('dropup');
	});
	
	
	//prevent dropdowns from hiding when a tab is selected
	$(document).on('click', '.dropdown-navbar .nav-tabs', function(e){
		e.stopPropagation();
		var $this , href
		var that = e.target
		if( ($this = $(e.target).closest('[data-toggle=tab]')) && $this.length > 0) {
			$this.tab('show');
			e.preventDefault();
		}
	});
	
	//prevent dropdowns from hiding when a from is clicked
	/**$(document).on('click', '.dropdown-navbar form', function(e){
		e.stopPropagation();		
	});*/


	//disable navbar icon animation upon click
	$('.ace-nav [class*="icon-animated-"]').closest('a').one('click', function(){
		var icon = $(this).find('[class*="icon-animated-"]').eq(0);
		var $match = icon.attr('class').match(/icon\-animated\-([\d\w]+)/);
		icon.removeClass($match[0]);
	});


	//tooltip in sidebar items
	$('.sidebar .nav-list .badge[title],.sidebar .nav-list .badge[title]').each(function() {
		var tooltip_class = $(this).attr('class').match(/tooltip\-(?:\w+)/);
		tooltip_class = tooltip_class ? tooltip_class[0] : 'tooltip-error';
		$(this).tooltip({
			'placement': function (context, source) {
				var offset = $(source).offset();

				if( parseInt(offset.left) < parseInt(document.body.scrollWidth / 2) ) return 'right';
				return 'left';
			},
			container: 'body',
			template: '<div class="tooltip '+tooltip_class+'"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
		});
	});
	
	//or something like this if items are dynamically inserted
	/**
	$('.sidebar').tooltip({
		'placement': function (context, source) {
			var offset = $(source).offset();

			if( parseInt(offset.left) < parseInt(document.body.scrollWidth / 2) ) return 'right';
			return 'left';
		},
		selector: '.nav-list .badge[title],.nav-list .label[title]',
		container: 'body',
		template: '<div class="tooltip tooltip-error"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
	});
	*/
	
	


	//the scroll to top button
	var scroll_btn = $('.btn-scroll-up');
	if(scroll_btn.length > 0) {
		var is_visible = false;
		$(window).on('scroll.scroll_btn', function() {
			var scroll = ace.helper.scrollTop();
			var h = ace.helper.winHeight();
			var body_sH = document.body.scrollHeight;
			if(scroll > parseInt(h / 4) || (scroll > 0 && body_sH >= h && h + scroll >= body_sH - 1)) {//|| for smaller pages, when reached end of page
				if(!is_visible) {
					scroll_btn.addClass('display');
					is_visible = true;
				}
			} else {
				if(is_visible) {
					scroll_btn.removeClass('display');
					is_visible = false;
				}
			}
		}).triggerHandler('scroll.scroll_btn');

		scroll_btn.on(ace.click_event, function(){
			var duration = Math.min(500, Math.max(100, parseInt(ace.helper.scrollTop() / 3)));
			$('html,body').animate({scrollTop: 0}, duration);
			return false;
		});
	}


	//chrome and webkit have a problem here when resizing from 479px to more
	//we should force them redraw the navbar!
	if( ace.vars['webkit'] ) {
		var ace_nav = $('.ace-nav').get(0);
		if( ace_nav ) $(window).on('resize.webkit' , function(){
			ace.helper.redraw(ace_nav);
		});
	}
	
	
	//fix an issue with ios safari, when an element is fixed and an input receives focus
	if(ace.vars['ios_safari']) {
	  $(document).on('ace.settings.ios_fix', function(e, event_name, event_val) {
		if(event_name != 'navbar_fixed') return;

		$(document).off('focus.ios_fix blur.ios_fix', 'input,textarea,.wysiwyg-editor');
		if(event_val == true) {
		  $(document).on('focus.ios_fix', 'input,textarea,.wysiwyg-editor', function() {
			$(window).on('scroll.ios_fix', function() {
				var navbar = $('#navbar').get(0);
				if(navbar) ace.helper.redraw(navbar);
			});
		  }).on('blur.ios_fix', 'input,textarea,.wysiwyg-editor', function() {
			$(window).off('scroll.ios_fix');
		  })
		}
	  }).triggerHandler('ace.settings.ios_fix', ['navbar_fixed', $('#navbar').css('position') == 'fixed']);
	}


	/**
	//TODO ... modal like display of navbar dropdowns in small devices
	$('.ace-nav > li').on('shown.bs.dropdown', function(e) {
	})
	*/

}




//some functions
ace.helper.collapsible = function() {
	var toggle
	return (document.querySelector('#sidebar.navbar-collapse') != null)
	&& ((toggle = document.querySelector('.navbar-toggle[data-target*=".sidebar"]')) != null)
	&&  toggle.scrollHeight > 0
	//sidebar is collapsible and collapse button is visible?
}
ace.helper.mobile_view = function() {
	var toggle
	return ((toggle = document.getElementById('menu-toggler')) != null	&& toggle.scrollHeight > 0)
}

ace.helper.redraw = function(elem) {
	var saved_val = elem.style['display'];
	elem.style.display = 'none';
	elem.offsetHeight;
	elem.style.display = saved_val;
}

ace.helper.scrollTop = function() {
	return document.scrollTop || document.documentElement.scrollTop || document.body.scrollTop
	//return $(window).scrollTop();
}
ace.helper.winHeight = function() {
	return window.innerHeight || document.documentElement.clientHeight;
	//return $(window).innerHeight();
}
ace.helper.camelCase = function(str) {
	return str.replace(/-([\da-z])/gi, function(match, chr) {
	  return chr ? chr.toUpperCase() : '';
	});
}
ace.helper.removeStyle = 
  'removeProperty' in document.documentElement.style
  ?
  function(elem, prop) { elem.style.removeProperty(prop) }
  :
  function(elem, prop) { elem.style[ace.helper.camelCase(prop)] = '' }


ace.helper.hasClass = 
  'classList' in document.documentElement
  ?
  function(elem, className) { return elem.classList.contains(className); }
  :
  function(elem, className) { return elem.className.indexOf(className) > -1; };

/**
 <b>Widget boxes</b>
*/
ace.widget_boxes = function($) {
	//bootstrap collapse component icon toggle
	$(document).on('hide.bs.collapse show.bs.collapse', function (ev) {
		var panel_id = ev.target.getAttribute('id')
		var panel = $('a[href*="#'+ panel_id+'"]');
		if(panel.length == 0) panel = $('a[data-target*="#'+ panel_id+'"]');
		if(panel.length == 0) return;

		panel.find(ace.vars['.icon']).each(function(){
			var $icon = $(this)

			var $match
			var $icon_down = null
			var $icon_up = null
			if( ($icon_down = $icon.attr('data-icon-show')) ) {
				$icon_up = $icon.attr('data-icon-hide')
			}
			else if( $match = $icon.attr('class').match(/fa\-(.*)\-(up|down)/) ) {
				$icon_down = 'fa-'+$match[1]+'-down'
				$icon_up = 'fa-'+$match[1]+'-up'
			}

			if($icon_down) {
				if(ev.type == 'show') $icon.removeClass($icon_down).addClass($icon_up)
					else $icon.removeClass($icon_up).addClass($icon_down)
					
				return false;//ignore other icons that match, one is enough
			}

		});
	})


	var Widget_Box = function(box, options) {
		this.$box = $(box);
		var that = this;
		//this.options = $.extend({}, $.fn.widget_box.defaults, options);

		this.reload = function() {
			var $box = this.$box;
			var $remove_position = false;
			if($box.css('position') == 'static') {
				$remove_position = true;
				$box.addClass('position-relative');
			}
			$box.append('<div class="widget-box-overlay"><i class="'+ ace.vars['icon'] + 'loading-icon fa fa-spinner fa-spin fa-2x white"></i></div>');

			$box.one('reloaded.ace.widget', function() {
				$box.find('.widget-box-overlay').remove();
				if($remove_position) $box.removeClass('position-relative');
			});
		}

		this.close = function() {
			var $box = this.$box;
			var closeSpeed = 300;
			$box.fadeOut(closeSpeed , function(){
					$box.trigger('closed.ace.widget');
					$box.remove();
				}
			)
		}
		
		this.toggle = function(type, button) {
			var $box = this.$box;
			var $body = $box.find('.widget-body');
			var $icon = null;
			
			var event_name = typeof type !== 'undefined' ? type : ($box.hasClass('collapsed') ? 'show' : 'hide');
			var event_complete_name = event_name == 'show' ? 'shown' : 'hidden';

			if(typeof button === 'undefined') {
				button = $box.find('> .widget-header a[data-action=collapse]').eq(0);
				if(button.length == 0) button = null;
			}

			if(button) {
				$icon = button.find(ace.vars['.icon']).eq(0);

				var $match
				var $icon_down = null
				var $icon_up = null
				if( ($icon_down = $icon.attr('data-icon-show')) ) {
					$icon_up = $icon.attr('data-icon-hide')
				}
				else if( $match = $icon.attr('class').match(/fa\-(.*)\-(up|down)/) ) {
					$icon_down = 'fa-'+$match[1]+'-down'
					$icon_up = 'fa-'+$match[1]+'-up'
				}
			}

			var expandSpeed   = 250;
			var collapseSpeed = 200;

			if( event_name == 'show' ) {
				if($icon) $icon.removeClass($icon_down).addClass($icon_up);

				$body.hide();
				$box.removeClass('collapsed');
				$body.slideDown(expandSpeed, function(){
					$box.trigger(event_complete_name+'.ace.widget')
				})
			}
			else {
				if($icon) $icon.removeClass($icon_up).addClass($icon_down);
				$body.slideUp(collapseSpeed, function(){
						$box.addClass('collapsed')
						$box.trigger(event_complete_name+'.ace.widget')
					}
				);
			}
		}
		
		this.hide = function() {
			this.toggle('hide');
		}
		this.show = function() {
			this.toggle('show');
		}
		
		
		this.fullscreen = function() {
			var $icon = this.$box.find('> .widget-header a[data-action=fullscreen]').find(ace.vars['.icon']).eq(0);
			var $icon_expand = null
			var $icon_compress = null
			if( ($icon_expand = $icon.attr('data-icon1')) ) {
				$icon_compress = $icon.attr('data-icon2')
			}
			else {
				$icon_expand = 'fa-expand';
				$icon_compress = 'fa-compress';
			}
			
			
			if(!this.$box.hasClass('fullscreen')) {
				$icon.removeClass($icon_expand).addClass($icon_compress);
				this.$box.addClass('fullscreen');
			}
			else {
				$icon.addClass($icon_expand).removeClass($icon_compress);
				this.$box.removeClass('fullscreen');
			}
			
			this.$box.trigger('fullscreened.ace.widget')
		}

	}
	
	$.fn.widget_box = function (option, value) {
		var method_call;

		var $set = this.each(function () {
			var $this = $(this);
			var data = $this.data('widget_box');
			var options = typeof option === 'object' && option;

			if (!data) $this.data('widget_box', (data = new Widget_Box(this, options)));
			if (typeof option === 'string') method_call = data[option](value);
		});

		return (method_call === undefined) ? $set : method_call;
	};


	$(document).on('click.ace.widget', '.widget-header a[data-action]', function (ev) {
		ev.preventDefault();

		var $this = $(this);
		var $box = $this.closest('.widget-box');
		if( $box.length == 0 || $box.hasClass('ui-sortable-helper') ) return;

		var $widget_box = $box.data('widget_box');
		if (!$widget_box) {
			$box.data('widget_box', ($widget_box = new Widget_Box($box.get(0))));
		}

		var $action = $this.data('action');
		if($action == 'collapse') {
			var event_name = $box.hasClass('collapsed') ? 'show' : 'hide';

			var event
			$box.trigger(event = $.Event(event_name+'.ace.widget'))
			if (event.isDefaultPrevented()) return

			$widget_box.toggle(event_name, $this);
		}
		else if($action == 'close') {
			var event
			$box.trigger(event = $.Event('close.ace.widget'))
			if (event.isDefaultPrevented()) return

			$widget_box.close();
		}
		else if($action == 'reload') {
			$this.blur();
			var event
			$box.trigger(event = $.Event('reload.ace.widget'))
			if (event.isDefaultPrevented()) return

			$widget_box.reload();
		}
		else if($action == 'fullscreen') {
			var event
			$box.trigger(event = $.Event('fullscreen.ace.widget'))
			if (event.isDefaultPrevented()) return
		
			$widget_box.fullscreen();
		}
		else if($action == 'settings') {
			$box.trigger('setting.ace.widget')
		}

	});

};

