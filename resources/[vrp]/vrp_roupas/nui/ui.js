let roupaID = null;
let dataPart = null;
let sexoLoja = 'Male';
let dataCat = 'mascara';
let change = {}
let oldPart = {}

$(document).ready(function() {
    document.onkeydown = function(data) {
        switch(data.keyCode) {
            case 27:
                $("body").fadeOut();
                $('#listagem').html('');
                $("body").fadeOut();
                $('#totalDireita').html('0'); 
                change = {};
                $.post('http://vrp_roupas/reset', JSON.stringify({}))
            break;

            case 68:
                $.post('http://vrp_roupas/rotate', JSON.stringify("left"))
            break;

            case 65:
                $.post('http://vrp_roupas/rotate', JSON.stringify("right"))
            break;

            case 88:
                $.post('http://vrp_roupas/handsup', JSON.stringify({}))
            break;
        }
    }

    $("#esquerda").click(function() {
        $.post('http://vrp_roupas/leftHeading', JSON.stringify({ value: 10 }));
    })

    $("#maos").click(function() {
        $.post('http://vrp_roupas/handsUp', JSON.stringify({}));
    })

    $("#direita").click(function() {
        $.post('http://vrp_roupas/rightHeading', JSON.stringify({ value: 10 }));
    })

    $("#cart").click(function() {
        $("body").fadeOut()
        $.post('http://vrp_roupas/payament', JSON.stringify({ parts: oldPart }));
        change = {};
    })

    window.addEventListener('message', function(event) {
        let item = event.data;
        
        if (item.openLojaRoupa) {
            oldPart = item.oldCustom
            change = {};
            $("body").fadeIn()
            dataPart = item.category
            $('#listagem').html('')
            if(item.category == 'p2' || item.category == 'p6'|| item.category == 'p7'){                    
                $("#listagem").append(`
                    <div class="item lista" data-id="-1" onclick="select(this)" id="${item.category}-1">
                        <div class="item-photo" style="background-image: url('http://177.54.148.31:4020/clothes/${item.sexo}/${item.category}/${i}_0.png'), url('https://media.discordapp.net/attachments/646512396285902851/859145319568637952/unknown.png');"></div>
                        <span>N ${i}</span>
                        <div class="price">FREE</div>
                    </div>
                `);
            }

            for (var i = 0; i <= (item.drawa -1); i++) {   
                var exibeItem = true;
                
                if(exibeItem){
                    $("#listagem").append(`
                        <div class="item lista" data-id="${i}" onclick="select(this)" id="${item.category}${i}">
                            <div class="item-photo" style="background-image: url('http://177.54.148.31:4020/clothes/${item.sexo}/${item.category}/${i}_0.png'), url('https://media.discordapp.net/attachments/646512396285902851/859145319568637952/unknown.png'); "></div>
                            <span>N ${i}</span>
                            <div class="price">FREE</div>
                        </div>
                    `);
                    if (oldPart[item.category][0] == i) {
                        select2(i);
                    }  
                }  
            };
        }
        if (item.changeCategory) {
            sexoLoja = item.sexo;
            dataPart = item.category;
            $('#listagem').html('');
            if(item.category == 'p2' || item.category == 'p6'|| item.category == 'p7'){                                  
                $("#listagem").append(`
                    <div class="item lista" data-id="-1" onclick="select(this)" id="${item.category}-1">
                        <span>N ${i}</span>
                        <img src="https://cdn.discordapp.com/attachments/646512396285902851/861123160119312404/trash.png">
                        <div class="price">FREE</div>
                    </div>
                `);
            }
            for (var i = 0; i <= (item.drawa -1); i++) {     
                exibeItem = true;
                
                if(exibeItem){
                    $("#listagem").append(`
                        <div class="item lista" data-id="${i}" onclick="select(this)" id="${item.category}${i}">
                            <div class="item-photo" style="background-image: url('http://177.54.148.31:4020/clothes/${item.sexo}/${item.category}/${i}_0.png'), url('https://media.discordapp.net/attachments/646512396285902851/859145319568637952/unknown.png');"></div>
                            <span>N ${i}</span>
                            <div class="price">FREE</div>
                        </div>
                    `);
                    if (oldPart[item.category][0] == i) {
                        select2(i);
                    }  
                }  

            };            
        }

        if(item.changeCategoryColor) {
            $('#listaCores').html('')   
            let itemMax = item.max - 1;      
            for (var i = 0; i <= itemMax; i++) {             
                $("#listaCores").append(`
                    <div class="item listaCor" id="color${i}" onclick="selectColor(this, ${i})"> 
                        <img src="http://177.54.148.31:4020/clothes/${item.sexo}/${item.category}/${roupaID}_${i}.png" onerror="this.src='http://177.54.148.31:4020/inventario/none.png'">
                    </div>
                `);
                if (oldPart[item.category][1] == i) {
                    selectColor2(i);
                }
            };      
        }

        if(item.atualizaRoupa) { 
            oldPart[dataPart][1] = item.color;
        }
    })
});

function inArray(needle, haystack) {
    var length = haystack.length;
    for(var i = 0; i < length; i++) {
        if(haystack[i] == needle) return true;
    }
    return false;
}

function update_valor() {
    const formatter = new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2 })
    let total = 0
    for (let key in change) { if (!change[key] == 0) { total += 40 } }
    $('#totalDireita').html(formatter.format(total))
}


function selectPart(element) {    
    let dataPart = element.dataset.idpart;
    dataCat = dataPart;
    $('.category .item').removeClass('ativada');
    $(element).addClass('ativada');    
    $('#listaCores').html('');
    $.post('http://vrp_roupas/changePart', JSON.stringify({ part: dataPart }));
}

function select(element) {
    roupaID = element.dataset.id;

    $('.lista').removeClass('selected');
    $(element).addClass('selected'); 

    oldPart[dataPart][0] = roupaID;
    oldPart[dataPart][1] = 0;
    $.post('http://vrp_roupas/changeCustom', JSON.stringify({ type: dataPart, id: roupaID, color: 0 }));    
    $.post('http://vrp_roupas/updateColor', JSON.stringify({ part: dataCat }));
}

function select2(id) {
    roupaID = id;
    $('.lista').removeClass('selected');
    $(`#${dataPart}${id}`).addClass('selected'); 
    oldPart[dataPart][0] = roupaID;   
    $.post('http://vrp_roupas/changeCustom', JSON.stringify({ type: dataPart, id: roupaID, color: oldPart[dataPart][1] }));
    $.post('http://vrp_roupas/updateColor', JSON.stringify({ part: dataCat }));
}

function selectColor(element, id){    
    $('.listaCor').removeClass('selected');
    $(element).addClass('selected'); 
    $.post('http://vrp_roupas/changeCustom', JSON.stringify({ type: dataPart, id: roupaID, color: id }));
}

function selectColor2(id){    
    $('.listaCor').removeClass('selected');
    $('#color'+id).addClass('selected'); 
}

$("#search").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $("#listagem .item").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
});