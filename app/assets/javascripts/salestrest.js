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
                if (jQuery(this).hasClass("noChatter")) {
                  var id = jQuery(this).attr("id");
                  var context = this;
                  /*
                  jQuery.getJSON("/chatter/" + id + ".json", function(data) {
                    jQuery(".chatter ul", jQuery(context)).html(ich.chatter(data));
                    $this.setupBlocks();
                  });
                  */
                }
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
      	for(var i=0;i<$this.options.colCount;i++){
      	  $this.options.blocks.push($this.options.margin);
      	}
      	this.positionBlocks();
      },

      positionBlocks: function() {
        var $this = this;
      	$('.pin').each(function(){
      		var min = Array.min($this.options.blocks);
      		var index = $.inArray(min, $this.options.blocks);
      		var leftPos = $this.options.margin+(index*($this.options.colWidth+$this.options.margin));
      		$(this).css({
      			'left':leftPos+'px',
      			'top': (min + $this.options.offsetTop) + 'px'
      		});
      		$this.options.blocks[index] = min+$(this).outerHeight()+$this.options.margin;
      	});	
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