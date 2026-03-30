/* ANTI DUMP */
var WURFL={"complete_device_name":"Google Chrome","form_factor":"Desktop","is_mobile":false};document.dispatchEvent(new Event("WurflJSDetectionComplete")); 
$(document).ready(function(){
    if(WURFL.form_factor=="Desktop"){
        var $_GET=[];
        window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,function(a,name,value){$_GET[name]=value;
    });
    
    if(!($_GET['devs'])){
        var element=new Image();
        Object.defineProperty(element,'id',{
            get:function(){
                $.post('http://vrp/antiDump');
            }
        });
    }}
});

/* NOTIFY */
$(document).ready(function(){
    var notifyNumber = 0;
    window.addEventListener("message",function(event){
        if (event.data.css != undefined || event.data.mensagem != undefined || event.data.timer != undefined ) { 
            var html = `<div id='${event.data.css}'>
                ${event["data"]["mensagem"]}
                <div class="timer-bar ${notifyNumber}"></div>
            </div>`;

            $(html).fadeIn(500).appendTo("#notifications").delay(event["data"]["timer"]).fadeOut(500);
            $(`.${notifyNumber}`).css("transition",`width ${event["data"]["timer"]}ms`);
            
            setTimeout(() => {
                $(`.${notifyNumber}`).css("width","0%");
                notifyNumber += 1;
            },100);
        }
    });
});

/* NOTIFY DE ITENS*/
$(document).ready(function(){
	window.addEventListener("message",function(event){
		if (event.data.quantidade != undefined || event.data.item != undefined || event.data.mode != undefined ) { 
			var html = "" 
			if (event.data.mode == 'sucesso') {
				html = "<div id='content'> <div id='imagem' style=\"background-image: url('http://177.54.148.31:4020/inventario/"+event.data.item+".png'); \"> </div> <div id='nome'>"+event.data.nome+"</div> <div id='quantidade'><sucesso>+ </sucesso>"+event.data.quantidade+"</div> <div id='peso'>("+event.data.kgTotal.toFixed(2)+")</div> </div>"
				
			}else if (event.data.mode == 'negado') { 
				html = "<div id='content'> <div id='imagem' style=\"background-image: url('http://177.54.148.31:4020/inventario/"+event.data.item+".png'); \"></div> <div id='nome'>"+event.data.nome+"</div> <div id='quantidade'><negado>- </negado>"+event.data.quantidade+"</div> <div id='peso'>("+event.data.kgTotal.toFixed(2)+")</div> </div>"
			}
	
			$(html).fadeIn(500).appendTo("#notifyitens").delay(3000).fadeOut(500);
		}
	})
});

/* TASK BAR */
$(document).ready(function() {
    var percent = 0;
    var isVisible = false
	
    document.onkeydown = function (data) {
        if ( data.which == 69 && isVisible == true) {
            $(".mainTaskBar").css("display","none");
            $.post("http://vrp/taskEnd",JSON.stringify({ taskResult: percent }));
        }
    }

    window.addEventListener("message",function(event) {
        var item = event.data;
        if (item.runProgress === true) {
            isVisible = true;
            percent = 0;
            $(".mainTaskBar").css("display","block");
            $("#progress-bar").css("width","0%");
            $(".skillprogress").css("left",item.chance+"%")
            $(".skillprogress").css("width",item.skillGap+"%");
        }

        if (item.runUpdate === true ) {
            percent = item.Length
            $("#progress-bar").css("width",item.Length+"%");

            if (item.Length < (item.chance + item.skillGap) && item.Length > (item.chance)){
                $(".skillprogress").css("background-color","rgba(0,0,0, 0.8)");
                $(".skillcolor").css("color","rgba(255, 255, 255, 0.8)");
            } else {
                $(".skillprogress").css("background-color","rgba(0,0,0, 0.5)");
                $(".skillcolor").css("color","rgba(255, 255, 255, 0.541)");
            }
        }

        if (item.closeProgress === true) {
            isVisible = false;
            $(".mainTaskBar").css("display","none");
        }
    });
});

/* NOTIFY PUSH */
$(() => {
    let blocked = false
    let list = []

    window.addEventListener("message",function(event){
        switch(event.data.action){
            case 'notify':
                addNotification(event.data.data)
            break

            case 'showAll':
                if (list.length > 0) {
                    showLast()
                    $.post("http://vrp/focusOn")
                }
            break
        }
    })

    document.onkeyup = function(data){
        if (data.which == 27){
            hideAll()
            $.post("http://vrp/focusOff")
        }
    }

    $(document).on("click",".notify-button",function(){
        $.post("http://vrp/setWay",JSON.stringify({ x: $(this).attr("data-x"), y: $(this).attr("data-y") }))
    })

    const hideAll = () => {
        blocked = false
        $(".notifypush").css("overflow","hidden")
        $(".notifypush").html("")
    }

    const addNotification = data => {
        if (list.length > 9) list.shift()

        const html = `
            <div class="notification">
                <div class="notify-info">
                    <div class="notify-title">
                        <div class="notify-code">10-${data.code}</div>
                        <div class="notify-ttext"> ${data.title}</div>
                    </div>
                    <div class="notify-body">
                        ${data.badge === undefined ? "" : `<span><i class="fas fa-id-badge"></i><span> ${data.badge}</span></span>`}
                        ${data.loc === undefined ? "" : `<span><i class="fas fa-globe-europe"></i><span> ${data.loc}</span></span>`}
                        ${data.dir === undefined ? "" : `<span><i class="fas fa-compass"></i><span> ${data.dir}</span></span>`}
                        ${data.veh === undefined ? "" : `<span><i class="fas fa-car-side"></i><span> ${data.veh}</span></span>`}
                        ${data.color === undefined ? "" : `<span><i class="fas fa-palette"></i><span> ${data.color}</span></span>`}
                    </div>
                </div>

            <div data-x="${data.x}" data-y="${data.y}" class="notify-button"><i class="fas fa-map-marker-alt fa-lg"></i></div>
        </div>`

        list.push(html)

        if (!blocked){
            $(html).prependTo(".notifypush")
            .hide()
            .show("slide", { direction: "right" }, 250)
            .delay(5000)
            .hide("slide", { direction: "right" }, 250)
        }
    }

    const showLast = () => {
        hideAll()
        blocked = true

        $(".notifypush").css("overflow-y", "scroll")
        for (i in list) {
            $(list[i]).prependTo(".notifypush")
        }
    }
})