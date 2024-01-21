<script>
    import { ShopItems , StockItems } from '../Data';
    import nail from '../assets/nailspic.png'
    import check from '../assets/check.png'

    let itemsAmount = 0
    function setchecked(data, index) {
       if($StockItems.find(e => e.itemName == data.itemName)) {
        $StockItems = $StockItems.filter(e => e.itemName !== data.itemName)
        return
       } else {
        let newdata = data
        newdata.ItemQuan = 1

        $StockItems.push(newdata)
        $StockItems = $StockItems
        return
       }
    }

    function addStock() {
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/addStock` , {method: 'POST' , body: JSON.stringify({items: $StockItems , amount: itemsAmount})}).then(d => d.json()).then(response => {
        //   alertsActions.addNotification(response.message , 'Nails')
        })
    }

</script>
<div class="Shop">
    <div class="ShopContainer" style="width: 22.4vw;height: 70vh">
        <div class="ShopHeader" style="padding-top: 2vh;">
            <h1>Beauty shop</h1>
            <div class="Line" style="margin-top: 1.5vh;width: 40%"></div>
            <img src={nail} style="margin-top: 0.5vh;height: 5vw">
        </div>
        <div class="ShopD" style="width: 100%;height: 56%">
            <div class="ShopItems" style="width: 100%;padding: 1vw; padding-bottom: 0.3vh">
                {#each $ShopItems as data,index}
                    <div class="ShopItem" >
                        <div class="checked" on:click={() => {setchecked(data,index)}}>
                            {#if $StockItems.find(e => e.itemName == data.itemName)}
                                <img src={check}>
                            {/if}
                        </div>
                        <p>{data.itemLabel}</p>
                        <img src={data.itemImage}>
                    </div>
                {/each}
            </div>
           
        </div>
        <div class="StocksUnderline">
            <div style="z-index: 9; flex-direction: row; justify-content: start; align-items: center; gap: 0.5vw" class="flexS">
                <p style="width: 40%;font-weight: bold;color: #5E5E5E; font-family: Bai Jamjuree; font-size: 0.5vw">Enter the amount of stocks needed for the items</p>
                <input type="number" style="width:2.2vw;height: 3.5vh" bind:value={itemsAmount}>
            </div>
            <div class="Bbutton" style="width: 7.5vw;z-index: 9;font-family: Bai Jamjuree; font-weight: bold" on:click={() => {addStock()}}>
                <p>Add</p>
            </div>
        </div>
      
    </div>
</div>