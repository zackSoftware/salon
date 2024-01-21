<script>
    import { showUI, nails , colors , NailsHair , hair ,Page} from '../Data.js'

    import NailsPic from '../assets/nailspic.png'
    import Hair from '../assets/hair.png'
    import btn from '../assets/btn.png'
    import AlertsManager from './alertsManager.svelte';


    let alertsActions
    let colorsSelected = [{hair: {hex: '0'},nail: {hex: '0'}}]



    let nailSelectedColor = 0
    let nailMaximumColor = 0

    

    function NextNail() {
        if($nails.current === $nails.max) return

        $nails.current = $nails.current + 1
        nailMaximumColor = $nails.nailsData[$nails.current-1].max
        fetch(`https://${GetParentResourceName()}/changeNail`, {method: 'POST' , body: JSON.stringify({num: $nails.current , type: $nails.nailsData[$nails.current-1].CategoryID })})
        nailSelectedColor = 0
    }

    function PreviousNail() {
        if($nails.current === 1) return
        $nails.current = $nails.current - 1
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/changeNail`, {method: 'POST' , body: JSON.stringify({num: $nails.current , type: $nails.nailsData[$nails.current-1].CategoryID })})
        nailMaximumColor = $nails.nailsData[$nails.current-1].max
        nailSelectedColor = 0
    }


    function nextNailColor() {
        if(nailSelectedColor === nailMaximumColor) return
        nailSelectedColor = nailSelectedColor + 1
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/changeNailColor`, {method: 'POST' , body: JSON.stringify({num: nailSelectedColor})})
    }

    function PreviousNailColor() {
        if(nailSelectedColor === 0) return
        nailSelectedColor = nailSelectedColor -1 
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/changeNailColor`, {method: 'POST' , body: JSON.stringify({num: nailSelectedColor})})

    }

    function NextHair() {
        if($hair.current === $hair.max) return

        $hair.current = $hair.current + 1
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/changeHair`, {method: 'POST' , body: JSON.stringify({num: $hair.current})})

    }

    function PreviousHair() {
        if($hair.current === 0) return
        $hair.current = $hair.current - 1
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/changeHair`, {method: 'POST' , body: JSON.stringify({num: $hair.current})})


    }

    

    function calcPercentage(current , max) {
        
        return (current/max)*100
    }

    function apply(act) {
        if(act == 'Nails') {
            // @ts-ignore
            fetch(`https://${GetParentResourceName()}/saveNails`, {method: 'POST' , body: JSON.stringify({})})
    
            $showUI = false
            alertsActions.addNotification('Nails Successfully <span style="color: green">Applied</span> ')
        } else {
            // @ts-ignore
            fetch(`https://${GetParentResourceName()}/saveHair`, {method: 'POST' , body: JSON.stringify({})})
      
            $showUI = false
            alertsActions.addNotification('Hair Successfully <span style="color: green">Applied</span> ' , 'Hair')
        }
    }
</script>
<div class="ApplyNailsAndHair">
    <div style="display: none">
        <AlertsManager bind:this={alertsActions}></AlertsManager>
    </div>
    {#if $NailsHair === 'Nails'  || $NailsHair === 'both'}
        <div class="Applyc">
            <div class="ApplycHeader">
                <h1>Beauty salon</h1>
                <div style="width: 100%;margin-top: 1vh" class="Line"></div>
                <img style="margin-top: 0.5vh;height: 5.5vw" src={NailsPic}>

            </div>
            <div class="slider" style="margin-top: 1vh;">
                <p>NAIL Type</p>
                <div>
                    <div  on:click={()=> {PreviousNail()}} class="arrowButton">
                        <img src={btn}>
                    </div>
                    <div class="sliderElem">
                        <p>{$nails.current}/{$nails.max}</p>
                        <div class="sliderAm" style="width: {calcPercentage($nails.current , $nails.max)}%"></div>
                    </div>
                    <div  on:click={()=> {NextNail()}} class="arrowButton">
                        <img style="transform: rotate(-180deg);" src={btn}>
                    </div>
                </div>
        
            </div>
            <div class="slider" style="margin-top: 1vh;">
                <p>NAIL COLOR</p>
                <div>
                    <div  on:click={()=> {PreviousNailColor()}} class="arrowButton">
                        <img src={btn}>
                    </div>
                    <div class="sliderElem">
                        <p>{nailSelectedColor}/{nailMaximumColor}</p>
                        <div class="sliderAm" style="width: {calcPercentage(nailSelectedColor, nailMaximumColor)}%"></div>
                    </div>
                    <div  on:click={()=> {nextNailColor()}} class="arrowButton">
                        <img style="transform: rotate(-180deg);" src={btn}>
                    </div>
                </div>
        
            </div>

            <div class="ApplyBUTTON" on:click={() => {apply('Nails')}} style="margin-top: 5vh">
            <p style="width: 100%;">APPLY</p>
            </div>
        </div>
    {/if}
    {#if $NailsHair === 'Hair' || $NailsHair === 'both'}
        <div class="Applyc">
            <div class="ApplycHeader">
                <h1 style="margin-left: 0.2vw;">Beauty salon</h1>
                <div style="width: 100%;margin-top: 1vh" class="Line"></div>
                <img style="margin-top: 0.5vh;height: 5.3vw;width: 100%" src={Hair}>

            </div>
            <div class="slider" style="margin-top: 1vh;">
                <p>Hair Styles</p>
                <div>
                    <div  on:click={()=> {PreviousHair()}} class="arrowButton">
                        <img src={btn}>
                    </div>
                    <div class="sliderElem">
                        <p>{$hair.current}/{$hair.max}</p>
                        <div class="sliderAm" style="width: {calcPercentage($hair.current , $hair.max)}%"></div>
                    </div>
                    <div  on:click={()=> {NextHair()}} class="arrowButton">
                        <img style="transform: rotate(-180deg);" src={btn}>
                    </div>
                </div>
            </div>
            <div class="ColorsChoose" style="margin-top: 1vh;width:12vw;min-height: 5vh !important;">            
                <div class="Colors" style="padding: 0.4vw;margin-left: 0.4vw">
                {#each $colors as color}
                <div class="colorDiv" style='background-color:{color.hex};min-width: 1vw !important ; width: 1vw; height: 1vw;border: {colorsSelected[0].hair.hex === color.hex? '0.005vw solid white' : '0.005vw solid transparent'}' on:click={() => {colorsSelected[0].hair = color; fetch(`https://${GetParentResourceName()}/changeHairColor`, {method: 'POST' , body: JSON.stringify({num: color.id})})}} >

                    </div>
                {/each}
                </div>
            </div>
            <div class="ApplyBUTTON" on:click={() => {apply('hair')}}>
                <p style="width: 100%;">APPLY</p>
            </div>
        </div>
    {/if}
</div>