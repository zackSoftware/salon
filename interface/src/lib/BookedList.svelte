<script>
    import { Booked , colors } from '../Data.js'
    import NailsPic from '../assets/nailspic.png'
    import DialogPop from '../assets/dialogpop.png'
    import AlertsManager from './alertsManager.svelte';
    let alertsActions



    function findColor(id) {
       let c
       $colors.forEach(element => {
            if(element.id === id) {
                c = element.hex
                return
            }
        });
        return c
    }

    // {id: 1 , name: 'Shauna', partSelected: 'both' , nail: 'red' , nailHex: '#4287f5' , hair: 'cyan' , hairHex: '#FFFFFFF'}
    function setPos(name , id) {
        let targetEleme = document.getElementById(name).offsetTop
        let dialog = document.getElementById('dialogS')
        dialog.style.opacity = '0';
        setTimeout(() => {
            targetEleme = targetEleme - 230
        dialog.style.top = `${targetEleme}px`
        } , 100)
        // 
        let text = document.getElementById('describeDia')
        if($Booked[id].partSelected == 'Nails') {
            text.innerHTML =`${name.split('_')[0]} Has Selected <span style="color: ${findColor($Booked[id].colorSelected)}">${$Booked[id].colorSelected}</span> Nails`;
        } else if($Booked[id].partSelected == 'Hair') {
            text.innerHTML =`${name.split('_')[0]} Has Selected <span style="color: ${$Booked[id].colorSelected}">${$Booked[id].colorSelected}</span> Hair`;
        } else {
            text.innerHTML =`${name.split('_')[0]} Has Selected Hair Color <span style="color: ${findColor($Booked[id].colorSelected)}">${$Booked[id].colorSelected}</span> & Nails Color <span style="color: ${findColor($Booked[id].colorSelected)}"> ${$Booked[id].colorSelected}</span>`;
        }

        setTimeout(() => {
            dialog.style.opacity = '100';
        }, 200);
    }

    function acceptBook(name) {
        let user = name.split('_')[0]
        let id = name.split('_')[1]


        let dialog = document.getElementById('dialogS')
        dialog.style.opacity = '0';
   // @ts-ignore
   fetch(`https://${GetParentResourceName()}/confirmBook`, {method: 'POST' , body: JSON.stringify($Booked[id])})
        alertsActions.addNotification(`${user}'s Book Successfully <span style="color: green">Confirmed</span> `)
        $Booked.splice(id,1)
        $Booked = $Booked


    }

    function declineBook(name) {
        let user = name.split('_')[0]
        let id = name.split('_')[1]


        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/declineBook`, {method: 'POST' , body: JSON.stringify($Booked[id])})

        let dialog = document.getElementById('dialogS')
        dialog.style.opacity = '0';

        alertsActions.addNotification(`${user}'s Book Successfully <span style="color: red">Declined</span> `)
        $Booked.splice(id,1)
        $Booked = $Booked
    }

    function acceptAll() {
          // @ts-ignore
        fetch(`https://${GetParentResourceName()}/confirmBook`, {method: 'POST' , body: JSON.stringify({all: true})}).then(res => res.json).then(r => {
            alertsActions.addNotification(`All book Successfully <span style="color: green">Confirmed</span> `)

            $Booked = []
            $Booked = $Booked 
        })
       
    }

    function declineAll() {
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/declineBook`, {method: 'POST' , body: JSON.stringify({all: true})}).then(res => res.json).then(r => {
            alertsActions.addNotification(`All book Successfully <span style="color: red">Declined</span> `)

            $Booked = []
            $Booked = $Booked 
        })
    }
</script>

<div class="bookedList">
    <div style="display: none">
        <AlertsManager bind:this={alertsActions}></AlertsManager>
    </div>
    <div id="dialogS">
        <p class="DescribeDialog" id="describeDia" style="position: absolute;">{@html ''}</p>
        <img src={DialogPop} id="popDia" class="DialogPOP">
    </div>
    <div class="bookedHeader">
        <h1>Beauty salon</h1>
        <div style="width: 80%;margin-top: 0.5vh" class="Line"></div>
        <img src={NailsPic}>
        <p>BOOKED APPOINTMENTS</p>
    </div>
    <div class="BOOKLIST">
        {#each $Booked as item,index}
            {#if item.accepted === 'none'}
                <div class="booklistItem" id='{item.name}_{index}'>
                    <p on:click={() => {setPos(`${item.name}_${index}` , index)}}>{item.name}</p>
                    <div class="booklistButtons">
                        <button on:click={() => {acceptBook(`${item.name}_${index}`)}}>Accept</button>
                        <button on:click={() => {declineBook(`${item.name}_${index}`)}} style="background-color: #521E1E">Decline</button>
                    </div>
                </div>
            {/if}
        {/each}
    
    </div>
    <div class="listBotttomButtons">
        <div on:click={() => {acceptAll()}} style="z-index: 9; cursor:pointer">
            <p>Accept all</p>
        </div>
        <div on:click={() => {declineAll()}} style="z-index: 9; cursor:pointer">
            <p>Decline all</p>
        </div>
    </div>
</div>