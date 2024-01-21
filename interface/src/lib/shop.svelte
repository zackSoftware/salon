<script>
    import { ShopItems } from '../Data';
    import { CartItems } from '../Data'

    import nail from '../assets/nailspic.png'
    import garbage from '../assets/garbage.png'
    import plus from '../assets/plus.svg'
    import minus from '../assets/minus.svg'

    import check from '../assets/check.png'
    import AlertsManager from './alertsManager.svelte'
    let alertsActions

    $: $CartItems, calcTotal();
    let totalValue = 0

    function setchecked(data, index) {
        fetch("./itemsStock.json").then(Response => Response.json()).then(r => {r.map(e => {
                if(e.itemName === data.itemName) {
                    if(e.quan === 0) {
                        
                        return 
                    } else {
                        if($CartItems.find(e => e.itemName == data.itemName)) {
                            $CartItems = $CartItems.filter(e => e.itemName !== data.itemName)
                            return
                        } else {
                            let newdata = data
                            newdata.ItemQuan = 1

                            $CartItems.push(newdata)
                            $CartItems = $CartItems
                            return

                        }
                    }
                }
            })
        });

      
    }

    function min(index) {
        if($CartItems[index].ItemQuan == 1) return
       
        $CartItems[index].ItemQuan = $CartItems[index].ItemQuan - 1
    }

    function add(index) {
        fetch("./itemsStock.json").then(Response => Response.json()).then(r => {r.map(a => {
                if(a.itemName === $CartItems[index].itemName) {
                    if(a.quan <= $CartItems[index].ItemQuan) {
                        return
                    } else {
                        $CartItems[index].ItemQuan = $CartItems[index].ItemQuan + 1
                        return
                    }
                }
            })
        })
        
    }

    function remove(index) {
       $CartItems.splice( index,1)
       $CartItems = $CartItems
    }

    function calcTotal() {
        let total = 0
        $CartItems.forEach(e => {
            total = total + ( e.ItemQuan * e.itemPrice)
        })
        totalValue = total
    }

    function Purchase() {
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/purchaseItems` , {method: 'POST' , body: JSON.stringify($CartItems)}).then(d => d.json()).then(response => {
          alertsActions.addNotification(response.message , 'Nails')
          $CartItems = []
        })
    }
</script>
<div class="Shop">
    <div class="ShopContainer">
        <div style="display: none">
            <AlertsManager bind:this={alertsActions}></AlertsManager>
        </div>
        <div class="ShopHeader">
            <h1>Beauty shop</h1>
            <div class="Line" style="margin-top: 1.5vh;width: 40%"></div>
            <img src={nail} style="margin-top: 0.5vh;height: 5vw">
        </div>
        <div class="ShopD">
            <div class="ShopItems">
                {#each $ShopItems as data,index}
                    <div class="ShopItem" >
                        <div class="checked" on:click={() => {setchecked(data,index)}}>
                            {#if $CartItems.find(e => e.itemName == data.itemName)}
                                <img src={check}>
                            {/if}
                        </div>
                        <p>{data.itemLabel}</p>
                        <img src={data.itemImage}>
                        <p style="height: 1vh;position: absolute; bottom: 0; margin-bottom: 0.6vh">${data.itemPrice}</p>
                    </div>
                {/each}
            </div>
            <div class="shopCart">
                <div class="shopCartItems">
                  
                    {#each $CartItems as data, index}
                        <div class="shopCartItem">
                            <div>
                                <img src={data.itemImage}>
                                <p>{data.itemLabel}</p>
                            </div>
                         
                            <div style="margin-right: 0.5vw;gap: 0.4vw">
                                <div class="cartButton" on:click={() => {min(index)}}><img src={minus}></div>
                                <div class="cartButton" on:click={() => {add(index)}}><img src={plus}></div>
                                <div class="cartButton" on:click={() => {remove(index)}}><img src={garbage}></div>

                            </div>
                            <div class="itemQ">
                                <p style="margin-left: 0">{data.ItemQuan}</p>
                            </div>
                        </div>
                    {/each}
                </div>

                <div class="shopCartButtn" style="padding-top: 3vh">
                    <div style="z-index: 9;" on:click={()=> {$CartItems = []}}>
                        <p>Clear</p>
                    </div>
                    <div on:click={() => {Purchase()}} style="background-color: #0E220D;color: #3B803A;box-shadow: 0px 0px 6px 0px #15950A;border: 0.1vw solid #3B803A;">
                        <p style="color: #3B803A;">Purchase</p>
                    </div>
                    <p style="position: absolute; bottom: 0; left: 0; margin-left: 2.5vw;color: white; font-family: Bai Jamjuree; margin-bottom: 5.5vh; font-size: 0.7vw; opacity: 0.6">${totalValue}</p>

                </div>

            </div>
        </div>
      
    </div>
</div>