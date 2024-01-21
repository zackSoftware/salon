<script>
    import {RequiredItems} from '../Data'
    import NailsPic from '../assets/nailspic.png'
    import AlertsManager from './alertsManager.svelte';
    let alertsActions;

    function PurchaseItem(data) {
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/PurchaseItem` , {method: 'POST',  body: JSON.stringify(data)}).then(d => d.json()).then(response => {
          alertsActions.addNotification(response.message , 'Nails')
        })
    }
</script>

<div class="RequiredItems" >
    <div style="display: none">
        <AlertsManager bind:this={alertsActions}></AlertsManager>
    </div>

    <div class="ReqHeader">
        <h1>Beauty salon</h1>
        <div style="width: 80%;margin-top: 0.5vh" class="Line"></div>
        <img src={NailsPic}>
        <p>REQUIRED ITEMS</p>
    </div>
    <div class="RequiredItemsList">
        {#each $RequiredItems as item,index}
        <div class="ListItemReq">
            <div style="gap: 0.2vw;justify-content: space-between;width: 4.5vw !important">
                <p>{item.label}</p>
                <p style="color: #28C21B;">${item.price}</p>
            </div>
            <div style="gap: 0.17vw;">
                <p style="font-size: 0.45vw;color:#999999">Amount</p>
                <input bind:value={item.quant}  style="width: 1.2vw;height: 1.5vh;padding: 0.1vw;text-align: center; font-size: 0.5vw" type="number">
            </div>
            <div class="booklistButtons" on:click={() => {PurchaseItem(item)}}>
                <button style="font-size: 0.4vw">Purchase</button>
            </div>
        </div>  
        {/each}

    </div>
    
</div>