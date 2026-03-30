let voice_bars = {
    1: document.querySelector('#v1'),
    2: document.querySelector('#v2'),
    3: document.querySelector('#v3')
}

function remove_voices_bars() {
    let elements = document.querySelectorAll('.qTalk')

    for (let i in elements ) {
        if (typeof elements[i] == 'object') {
            elements[i].classList.remove('activeQ')
            elements[i].style.background = 'rgba(255, 255, 255, 0.2)'
        }
    }
}

function talking_voice() {
    let elements = document.querySelectorAll('.activeQ')

    for (let i in elements ) {
        if (typeof elements[i] == 'object') {
            elements[i].style.background = 'rgb(58, 104, 161)'
        }
    }
}

function setVeloBar(velo) {
    let fill_value = 180 * (velo) / (300)

    let fill_element = document.querySelector('.veloFill')

    fill_element.style.width = `${fill_value}%`
}

function formatTime(minute, hour) {
    let time = ''

    if (hour <= 9) {
        time += '0' + hour
    } else {
        time += hour
    }

    if (minute <= 9) {
        time += ':0' + minute
    } else {
        time += ':' + minute
    }

    return time
}


window.addEventListener('message', ({ data }) => {
    if (data.hud) {
        let body = document.querySelector('.hud')
        body.style.display = 'flex'
    
        const talkText = document.querySelector('.talkText')
        if (data.voice == '1') {
            remove_voices_bars()
            voice_bars[1].classList.add('activeQ')
            voice_bars[1].style.background = 'white'
    
            talkText.textContent = 'Sussurrando'
        } else if (data.voice == '2') {
            remove_voices_bars()
            voice_bars[1].classList.add('activeQ')
            voice_bars[1].style.background = 'white'
    
            voice_bars[2].classList.add('activeQ')
            voice_bars[2].style.background = 'white'
    
            talkText.textContent = 'Normal'
        } else {
            voice_bars[1].classList.add('activeQ')
            voice_bars[1].style.background = 'white'
    
            voice_bars[2].classList.add('activeQ')
            voice_bars[2].style.background = 'white'
    
            voice_bars[3].classList.add('activeQ')
            voice_bars[3].style.background = 'white'
    
            talkText.textContent = 'Gritando'
        }
    
        if (data.talking) {
            talking_voice()
        }
    
    
        document.querySelector('#lifeFill').style.width = `${data.health}%`
        document.querySelector('#water').style.width =  `${data.sede}%`
        document.querySelector('#food').style.width =  `${data.fome}%`
        
        if (data.armour > 0 ) {
            document.querySelector('#shield-container').style.display = 'flex'
            document.querySelector('#shield').style.width =  `${data.armour}%`
        }else{
            document.querySelector('#shield-container').style.display = 'none'
        }
    
        let radio = document.querySelector('.radio')
    
        if (data.radiofreq > 0 && data.radiofreq != undefined) {
            radio.innerHTML = `<img src="images/freq.svg" alt=""> <p>${data.radiofreq} <span>Mhz</span></p>`
        } else {
            radio.innerHTML = '<img src="images/freq.svg" alt=""> <p>Desligado</p>'
        }
        
        let hour = document.querySelector('.hour')
        hour.textContent = `${data.time}`
    
        let location = document.querySelector('.location')
        location.innerHTML = `
            <img src="images/loc.svg" alt="">
            <p> ${data.street} <span style="color: white; margin: 3px;"></span></p>
        `
    
        let car = document.querySelector('.carHud-container')
        let normalHud = document.querySelector('.normalContainer')
        let footer = document.querySelector('footer')
    
        if (data.vehicle) {
            car.style.display = 'flex'
    
            normalHud.style.left = '50%'
            normalHud.style.transform = 'translateX(-50%)'
    
            footer.style.right = '230px'
    
            let velo = document.querySelector('.velo')
    
            velo.textContent = data.speed
    
            if (Number(data.speed) <= 9) {
                velo.innerHTML = `
                    <h1 class = 'velo'><span class = 'defaultVelo'>00</span>${data.speed.toFixed(0)}<span class = 'kmText'>KMH</span></h1>
                `
            } else if (Number(data.speed) <= 99) {
                velo.innerHTML = `
                    <h1 class = 'velo'><span class = 'defaultVelo'>0</span>${data.speed.toFixed(0)}<span class = 'kmText'>KMH</span></h1>
                `
            } else {
                velo.innerHTML = `
                    <h1 class = 'velo'>${data.speed.toFixed(0)}<span class = 'kmText'>KMH</span></h1>
                `
            }
    
            let velo_perc = 100 * (data.speed) / (300)
    
            setVeloBar(velo_perc)
    
            let gas_element = document.querySelector('.gasAmount')
            gas_element.innerHTML = `
                <p class = 'gasAmount'>${data.fuel.toFixed(0)}<span>%</span></p>
            `
            
            let seatbelt = document.querySelector('.seatbelt')
    
            if (data.seatbelt == '1') {
                seatbelt.classList.remove('opacity')
            } else {
                seatbelt.classList.add('opacity')
            }
        } else {
            car.style.display = 'none'
    
            normalHud.style.left = '40px'
            normalHud.style.transform = 'translateX(0%)'
    
            footer.style.right = '40px'
        }
    }else{
        let body = document.querySelector('.hud')
        body.style.display = 'none'
    }

    /* PROGRESSBAR */
    let timeout = false;

    if (data.display === true){
        clearTimeout(timeout);
        var start = new Date();
        var maxTime = data.time;
        var timeoutVal = Math.floor(maxTime/100);
        animateUpdate();
        $('#outerdiv').fadeIn()

        function updateProgress(percentage){
            $('#innerdiv').css("width",percentage+"%");
        }

        function animateUpdate(){
            var now = new Date();
            var timeDiff = now.getTime() - start.getTime();
            var perc = Math.round((timeDiff/maxTime)*100);
            if (perc <= 100) {
                updateProgress(perc);
                timeout = setTimeout(animateUpdate,timeoutVal);
            } else {
                updateProgress(0);
                $('#outerdiv').hide()
            }
        }
    }
})

const animateLogo = () => {
	setTimeout(() => {
		$("#logo").removeClass("logo-animation");
	}, 1000);
	setTimeout(() => {
		$("#logo").addClass("logo-animation");
		animateLogo();
	}, 6500);
}
  
animateLogo();