$(document).ready(function() {
    window.addEventListener('message', function(event) {
        let data = event.data
        if (data.action) {
            $(".spawn-wrapper").fadeIn(350);
            $('.tooltipped').tooltip();
            $(".map-wrapper").on("click",".Sbtn",function(){
                $(".spawn-wrapper").addClass("disabled");
                let location = $(this).attr("data-location");
                $.post('http://vrp_login/spawn', JSON.stringify({ location: location }));
    
    
                $(".spawn-wrapper").fadeOut(350);
                $(".spawn-wrapper").removeClass("disabled");
                $("body").css("background","transparent");
                $('.spawn-markers').hide();
            })
        }
    })
});