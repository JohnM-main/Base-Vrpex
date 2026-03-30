function addGaps(nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + '<span style="margin-left: 3px; margin-right: 3px;"/>' + '$2');
    }
    return x1 + x2;
}

function addCommas(nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + '.<span style="margin-left: 0px; margin-right: 1px;"/>' + '$2');
    }
    return x1 + x2;
}

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        var item = event.data;
        $('.identidade').html(item.identidade);
        $('#salario').html(item.salario)



        if (item.openBank == true) {
            $(".container").fadeIn();
            $('.currentBalance').html(' ' + addCommas(item.bank));
            $('.carteira').html(' ' + addCommas(item.cart));
            $("#multas #amount").val(item.multas);
        }

        if (item.updateBalance == true) {
            $('.currentBalance').html(' ' + addCommas(event.data.bank));
            $('.carteira').html(' ' + addCommas(event.data.cart));
            $("#multas #amount").val(event.data.multas);
            $("#saque #amount").val('');
            $("#depositar #amount").val('');
            $("#trans #amount").val('');
            $("#trans #toPlayer").val('');
        }

        if (item.openBank == false) {
            $(".container").fadeOut();
        }
    });

    document.onkeyup = function(data) {
        if (data.which == 27) {
            $.post('http://vrp_banco/close', JSON.stringify({}));
        }
    };

    $("#saque").submit(function(e) {
        e.preventDefault();
        if (parseInt($("#saque #amount").val()) && parseInt($("#saque #amount").val()) > 0 ) {
            $("#saque #amount").prop('disabled', false)
            $.post('http://vrp_banco/withdrawSubmit', JSON.stringify({
                amount: $("#saque #amount").val()
            }));

            setTimeout(function() {
                $("#sacar #amount").prop('disabled', false);
                $("#sacar #submit").css('display', 'block');
            }, 2000)
        }

    });

    $("#depositar").submit(function(e) {
        e.preventDefault();
        
        if (parseInt($("#depositar #amount").val()) && parseInt($("#depositar #amount").val()) > 0 ) {
            $("#depositar #amount").prop('disabled', false)
            $.post('http://vrp_banco/depositSubmit', JSON.stringify({
                amount: $("#depositar #amount").val()
            }));

            setTimeout(function() {
                $("#depositar #amount").prop('disabled', false);
                $("#depositar #submit").css('display', 'block');
            }, 2000)
        }

    });

    $("#trans").submit(function(e) {
        e.preventDefault();

        if (parseInt($("#trans #amount").val()) && parseInt($("#trans #amount").val()) > 0 && parseInt($("#trans #toPlayer").val()) && parseInt($("#trans #toPlayer").val()) > 0 ) {
            $("#trans #amount").prop('disabled', false)
            $.post('http://vrp_banco/transferSubmit', JSON.stringify({
                amount: $("#trans #amount").val(),
                toPlayer: $("#trans #toPlayer").val()
            }));

            setTimeout(function() {
                $("#trans #amount").prop('disabled', false);
                $("#trans #submit").css('display', 'block');
            }, 2000)
        }

    });

    $("#multas").submit(function(e) {
        e.preventDefault();
        if (parseInt($("#multas #amount").val()) && parseInt($("#multas #amount").val()) > 0 ) {
            $("#multas #amount").prop('disabled', false)
            $.post('http://vrp_banco/multasSubmit', JSON.stringify({
                amount: $("#multas #amount").val()
            }));
    
            setTimeout(function() {
                $("#multas #amount").prop('disabled', false);
                $("#multas #submit").css('display', 'block');
            }, 2000)
        }
    });

    $("#saquerapido1").click(function() {
        $.post('http://vrp_banco/withdrawSubmit', JSON.stringify({
            amount: parseInt($("#saquerapido1").data("value"))
        }));
    });

    $("#saquerapido2").click(function() {
        $.post('http://vrp_banco/withdrawSubmit', JSON.stringify({
            amount: parseInt($("#saquerapido2").data("value"))
        }));
    });

    $("#saquerapido3").click(function() {
        $.post('http://vrp_banco/withdrawSubmit', JSON.stringify({
            amount: parseInt($("#saquerapido3").data("value"))
        }));
    });

    $("#saquerapido4").click(function() {
        $.post('http://vrp_banco/withdrawSubmit', JSON.stringify({
            amount: parseInt($("#saquerapido4").data("value"))
        }));
    });

    $("#depositorapido1").click(function() {
        $.post('http://vrp_banco/depositSubmit', JSON.stringify({
            amount: parseInt($("#depositorapido1").data("value"))
        }));
    });

    $("#depositorapido2").click(function() {
        $.post('http://vrp_banco/depositSubmit', JSON.stringify({
            amount: parseInt($("#depositorapido2").data("value"))
        }));
    });

    $("#depositorapido3").click(function() {
        $.post('http://vrp_banco/depositSubmit', JSON.stringify({
            amount: parseInt($("#depositorapido3").data("value"))
        }));
    });

    $("#depositorapido4").click(function() {
        $.post('http://vrp_banco/depositSubmit', JSON.stringify({
            amount: parseInt($("#depositorapido4").data("value"))
        }));
    });

});