;(function ( $, window, document, undefined ) {

    var pluginName = 'salestrest',
        defaults = {
            object: "pins__c",
            callback: function() {},
            colCount: 0,
            colWidth: 0,
            margin: 20,
            offsetTop: 40,
            windowWidth: 0,
            blocks: []
        };

    // The actual plugin constructor
    function Salestrest( element, options ) {
        this.element = element;

        this.options = $.extend( {}, defaults, options) ;

        this._defaults = defaults;
        this._name = pluginName;

        this.init();
    }

    Salestrest.prototype = {
        
        init: function() {
            var elem = this.element
            var $this = this;
            var callback = this.options.callback;
            jQuery.getJSON('/sobjects/' + this.options.object + '.json', function(data) {
              jQuery(elem).append(ich.pin(data.data));
              $this.setupBlocks();
              jQuery(".pins li.pin").each(function() {
                  var id = jQuery(this).attr("id");
                  var context = this;
                    jQuery(".pinit a", jQuery(context)).live("click", function(e) {
                      
                          var $pinBtn = jQuery(this);
                          e.stopPropagation();
                          e.preventDefault();
                          
                          var unpinId = $pinBtn.attr("data-unpinId");
                          
                          if (unpinId == "") {

                            jQuery.ajax({
                              type: 'POST',
                              url: $pinBtn.attr("data-pinlink"),
                              success: function(a,b,c,d) {
                             
                                
                                $pinBtn.text("Unpin");
                                
                              },
                              error: function() {
                                alert("Error");
                              }
                            });
                          }
                          else {
                            if ($this.options.object == '___Pinned') {
                                jQuery(context).remove();
                                 $this.setupBlocks($this)
                            }
                            jQuery.ajax({
                              type: 'DELETE',
                              url: "/sobjects/pin/" + unpinId,
                              success: function(a,b,c,d) {
                                
                                
                                $pinBtn.text("Pin");
                                
                              },
                              error: function(a,b,c,d) {
                              }
                            });
                            
                          }
                    });
                    jQuery(".loadChatter", jQuery(context)).bind("click", function(e) {
                      jQuery(this).hide();
                      e.preventDefault();
                      jQuery(".chatterLoader", jQuery(context)).show();
                      jQuery.getJSON("/chatter/" + id + ".json", function(data) {
                        data.me = $this.options.me;
                        jQuery(".chatter ul", jQuery(context)).html(ich.chatter(data));
                        jQuery(".chatterLoader", jQuery(context)).hide();
                        
                        
                        
                        
                        
                        jQuery("input.comment", jQuery(context)).keypress(function(e) {
                          if (e.charCode == 13) {
                            
                            var newComment = jQuery(this).val();
                            var box = this;
                            var id = jQuery(context).attr('id');
                            
                            jQuery.ajax({
                              type: 'POST',
                              url: '/chatter',
                              data: {id: id, text: newComment},
                              success: function(e) {
                                var cdata = {author: $this.options.me, body: newComment}
                                jQuery("li.comment", jQuery(context)).after(ich.chatterComment(cdata));
                                jQuery(".noposts", jQuery(context)).hide();
                                jQuery(box).val("");
                                $this.setupBlocks($this)
                              }
                            });
                            
                          }
                        });
                        
                        $this.setupBlocks();
                      });
                  });
              });
              callback();
            });
            $(window).resize(function() {
              $this.setupBlocks($this)
            });
        },
        



      setupBlocks: function(obj) {
      	var $this = obj || this;
      	$this.options.windowWidth = $(window).width();
      	$this.options.colWidth = $('.pin').outerWidth();
      	$this.options.blocks = [];
      	$this.options.colCount = Math.floor($this.options.windowWidth/($this.options.colWidth+$this.options.margin*2));
      	$this.options.leftOffset = ($(window).width() / 2) * $this.options.colCount;
      	for(var i=0;i<$this.options.colCount;i++){
      	  $this.options.blocks.push($this.options.margin);
      	}
      	this.positionBlocks();
      },

      positionBlocks: function() {
        var $this = this;
        var max = 0;
      	$('.pin').each(function(){
      		var min = Array.min($this.options.blocks);
      		var index = $.inArray(min, $this.options.blocks);
      		var leftPos = $this.options.margin+(index*($this.options.colWidth+$this.options.margin));
      		$(this).css({
      			'left':leftPos+'px',
      			'top': (min + $this.options.offsetTop) + 'px'
      		});
      		$this.options.blocks[index] = min+$(this).outerHeight()+$this.options.margin;
      		if (( $(this).outerHeight()+$this.options.margin + Array.max($this.options.blocks)) > max) {
      		  max = $(this).outerHeight()+$this.options.margin + Array.max($this.options.blocks);
      		}
      	});	
        $($this.element).css({height: max});
      	
      }

    };

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, 'plugin_' + pluginName)) {
                $.data(this, 'plugin_' + pluginName,
                new Salestrest( this, options ));
            }
        });
    }

})( jQuery, window, document );

Array.min = function(array) {
    return Math.min.apply(Math, array);
};
Array.max = function(array) {
    return Math.min.apply(Math, array);
};