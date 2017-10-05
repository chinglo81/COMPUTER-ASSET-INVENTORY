
// Set mobile status
onResize = function ()
{
    mobile = $('.global-header-logo').css('left') == '60px' ? true : false;
}


$(document).ready( onResize );


// Main app jquery
$(document).ready( function ()
{

    // Select input text on focus
    $(document).on( 'focus' , 'input:text' , function () { $(this).select(); } );

    // Collapse header on scroll
    $(window).scroll( function ()
    {
        if( !mobile )
        {
            scroll_top = get_scroll();

            scroll_header( scroll_top );
        }
    });


    // Show navigation drawer
    if ( $('.button-global_menu').length )
    {
        $('.button-global_menu').on( 'click' , function ()
        {
            $('.nav-drawer-mask').fadeIn( 300 );
            $('.nav-drawer').css( 'transform' , 'translateX(0px)' );
        });
    }


    // Hide navigation drawer
    if( $('.nav-drawer-mask').length )
    {
        $(document).on( 'click' , '.nav-drawer-mask, .nav-drawer a' , function ()
        {
            hide_drawer();
        });
    }

});



// Window resize events
$(window).on( 'resize' , onResize );
$(window).resize( function ()
{
    if( mobile )
    {
        $('.scroll-header').removeClass( 'show' );
    }
    else
    {
        scroll_top = get_scroll();
        scroll_header( scroll_top );
    }
});



// === Custom Functions === //


// Scroll position
function get_scroll ()
{
    var y = 0;

    if( typeof( window.pageYOffset ) == 'number' ) {
        //Netscape compliant
        y = window.pageYOffset;
    } else if( document.body && document.body.scrollTop ) {
        //DOM compliant
        y = document.body.scrollTop;
    } else if( document.documentElement && document.documentElement.scrollTop ) {
        //IE6 standards compliant mode
        y = document.documentElement.scrollTop;
    }

    return y;
};



// Apply styles to header elements on scroll down
function scroll_header( scroll_top )
{
    if( scroll_top < 98 && $('.global-header-logo').hasClass('logo-scroll') )
    {
        $('.global-header-logo').removeClass( 'logo-scroll' );
    }
    else if( scroll_top >= 98 && !$('.global-header-logo').hasClass('logo-scroll') )
    {
        $('.global-header-logo').addClass( 'logo-scroll' );
    }
    
    if( scroll_top >= 98  && $('.scroll-header').is(':hidden') )
    {
        $('.scroll-header').addClass( 'show' );
    }
    else if( scroll_top < 98  && $('.scroll-header').is(':visible') )
    {
        $('.scroll-header').removeClass( 'show' );
    }
}



// Hide nav drawer
function hide_drawer()
{
    $('.nav-drawer').css( 'transform' , 'translateX(-241px)' );
    $('.nav-drawer-mask').fadeOut( 300 );
    setTimeout( function ()
    {
        $('.nav-drawer').removeAttr( 'style' );
    });
}