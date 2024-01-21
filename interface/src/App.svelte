<script>

  let showSideHelp = true
  
  
  import Background from './assets/bg.png'
  import Polygone from './assets/polygone.png'
  import AlertsManager from './lib/alertsManager.svelte';
  import ApplyNails from './lib/ApplyNails.svelte';
  import BookedList from './lib/BookedList.svelte';
  import Shop from './lib/shop.svelte';
  import Stocks from './lib/Stocks.svelte';
  import RequiredItemsD from './lib/RequiredItems.svelte'
  import {showUI , nails, hair , colors , Page , Booked, NailsHair, ShopItems , EmployeesList , BusinessEncomy , BusinessTargets , JobApplications, RequiredItems} from './Data';
    import Business from './lib/Business.svelte';
  let alertsActions

  let k = 'Main'

  let bookData = {}
  let applyData = {}

  function buttonClick(act) {
    if(act == 'book') {
      k = 'Book'
    }
    if(act == 'cancel') {
      k = 'Main'
    }

    if(act == 'apply') {
      k = 'Apply'
    }

    if(act == 'checkAppointment') {
      // @ts-ignore
      fetch(`https://${GetParentResourceName()}/checkAppointment` , {method: 'POST'}).then(d => d.json()).then(response => {
          alertsActions.addNotification(response.message , 'Nails')
        })
    }

    if(act == 'submitBook') {
      if(bookData.partSelected !== undefined && bookData.colorSelected !== undefined){
        $Page = 'Main'
        // @ts-ignore
        fetch(`https://${GetParentResourceName()}/submitBook` , {method: 'POST' , body: JSON.stringify(bookData)}).then(d => d.json()).then(response => {
        
          if(response.error !== true) {
            let partSelected = 'Nails'
            if(bookData.partSelected == 'hair') {
              partSelected = 'Hair'
            }
            alertsActions.addNotification('Appointment Booked <span style="color: green">Successfully</span> ', partSelected)
          } else {
            alertsActions.addNotification(`${response.message}` , 'Nails')
          }
        })
      }
    }

    if(act == 'submitApply') {
      if(applyData.fullName !== undefined && applyData.date !== undefined) {
         // @ts-ignore
        fetch(`https://${GetParentResourceName()}/submitApply` , {method: 'POST' , body: JSON.stringify(applyData)}).then(d => d.json()).then(response => {
          if(response.error !== true) {
            applyData.fullName = ''
            applyData.date = ''

            alertsActions.addNotification('Apply Form Sent <span style="color: green">Successfully</span>' , 'Nails')
          } else {
            alertsActions.addNotification(`${response.message}` , 'Nails')
          }
        })
      
      } 
      
    }
  }

  let displayProgress = false
  let progressTime = 6000
  let progressText = 'Hey'

  function Progress() {

    document.getElementById('ProgBar').style.width = '0%';
    document.getElementById('ProgText').textContent = progressText;

    let currentTime = 0;

    function updateProgress() {
        const progress = (currentTime / progressTime) * 100;
        document.getElementById('ProgBar').style.width = progress + '%';
        currentTime += 1000;

        if (progress < 100) {
          setTimeout(updateProgress, 1000);
        } else {
          setTimeout(() => {
             displayProgress = false
             document.getElementById('ProgBar').style.width = '0%';

             return
          }, 1000);
        }
    }

    updateProgress();
  }


  window.addEventListener('message' , function(e) {

    if(e.data.type == 'progress') {
      displayProgress = true
      progressTime = e.data.time
      progressText = e.data.text

      Progress()
    }

    if(e.data.type == 'show') {
      $Page = e.data.page
      if(e.data.page === 'ApplyNails') {
        $NailsHair = e.data.data.type
        if(e.data.data.type === 'Hair') {
            $hair.current = e.data.data.current
            $hair.max = e.data.data.max
        } else {
          $nails.current = e.data.data.current
          $nails.max = e.data.data.max
          $nails.nailsData = e.data.data.nailsData

          
        }
      }


      if(e.data.page === 'RequiredItems') {
        $Page = 'RequiredItems'
        $RequiredItems = e.data.data
      }

      if(e.data.page === 'Shop') {
        $ShopItems = e.data.data
      }

      if(e.data.page === 'Business') {
        $ShopItems = e.data.data.shopItems

        $EmployeesList = (e.data.data.b.businessEmployees)
        $BusinessEncomy = (e.data.data.b.businessEncomy)
        $BusinessTargets = e.data.data.b.Targets
        $JobApplications = e.data.data.b.JobApplications

      }
      if(e.data.page === 'bookedList') {
        $Booked = e.data.data
      }
      $showUI = true
    } else if(e.data.type == 'notification') {
      alertsActions.addNotification(`${e.data.message}` , 'Nails' , e.data.time)

    }
  })

  window.addEventListener('keyup' , function(e) {
    if(e.key === 'Escape') {
      $showUI = false

      fetch(`https://${GetParentResourceName()}/closeUI` , {method: 'POST' , body: JSON.stringify({businessData: $EmployeesList , page: $Page})})
      
 
    }
  })
</script>

<main>

  <div class="ProgBar" style="opacity: {displayProgress == true ? '100' : '0'}">
    <div class="ProgProg"  id="ProgBar"></div>
    <p id="ProgText">Hey</p>
  </div>

  <div class="NotificationsContainer" style="z-index: -1;">
    <AlertsManager bind:this={alertsActions}></AlertsManager>
  </div>

  <div class="Container" style="opacity: {$showUI == true ? '100' : '0'}" >
    {#if $Page == 'bookedList'}
      <BookedList/>
    {/if}
    {#if $Page == 'ApplyNails'}
      <ApplyNails/>
    {/if}
    {#if $Page == 'Shop'}
    <Shop/>
    {/if}
    {#if $Page == 'Business'}
    <Business/>
    {/if}
    {#if $Page == 'Stocks'}
    <Stocks/>
    {/if}
    {#if $Page == 'RequiredItems'}
    <RequiredItemsD/>
    {/if}

    
    <div class="MainPage" style="opacity: {$Page == 'Main' ? '100' : 0};">
      <div class="Side" style="display: {showSideHelp == true ? 'flex' : 'none'};">
        <div class="Close" on:click={() => {showSideHelp = !showSideHelp}} style="background-image: url({Polygone});">
          <p>X</p>
        </div>
        <div class="SideImage">
          <img src={Background}>
        </div>
        <div class="SideText">
          <p>If we’re not at the counter then call the number below please</p>
          <p style="color: white;margin-top: -1vh;padding-bottom: 1vh">+1(223)233-2333</p>
        </div>
      </div>
      <div class="Main" style="background-image: url({Background})">
        <div>
          <div class="Header">
            <h1>Beauty salon</h1>
            <div class="Line"></div>
            {#if k == 'Main' || k == 'Apply'} 
              <p>Experience instant nail glamour with our seamless salon appointment booking app. Elevate your nail game effortlessly</p>
            {/if}
            {#if k == 'Book'} 
              <p>Please specify your preferred nail or hair color when booking your appointment. Your choice is important for a personalized experience.</p>
            {/if}
          </div>
          <div class="MainContent" >
            {#if k == 'Main'} 
            <p style="margin-left: 2.1vw;width: 70%">YOUR ESCAPE 
              FROM EVERYDAY
              ROUTINES</p>
            {/if}
            {#if k == 'Book'} 
              <div class="ColorsChoose">
                <div class="ColorsHeader" style="display: flex;flex-direction: row; ">
                  <div on:click={() => {bookData.partSelected = 'Hair'}}>
                    <div class="CircleHeader" style="background-color: {bookData.partSelected == 'Hair' || bookData.partSelected == 'both' ? 'red' : 'transparent'}"></div>
                    <p>Hair</p>
                  </div>
                  <div on:click={() => {bookData.partSelected = 'Nails'}}>
                    <div class="CircleHeader" style="background-color: {bookData.partSelected == 'Nails' || bookData.partSelected == 'both' ? 'red' : 'transparent'}"></div>
                    <p>Nails</p>
                  </div>
                  <div on:click={() => {bookData.partSelected = 'both'}}>
                    <div class="CircleHeader" style="background-color: {bookData.partSelected == 'both' ? 'red' : 'transparent'}"></div>
                    <p>Both</p>
                  </div>
                </div>
                <div class="Colors" style="overflow: auto;max-height: 9vh">
                  {#each $colors as color}
                    <div class="colorDiv" on:click={()=> {bookData.colorSelected = color.id}} style="background: {color.hex};min-width: 1vw !important ; width: 1vw; height: 1vw;border: {bookData.colorSelected === color.id? '0.005vw solid white' : '0.005vw solid transparent'}">

                    </div>
                  {/each}
                </div>
              </div>
            {/if}
            {#if k == 'Apply'} 
            <div class="Apply">
              <div class="ApplyInputs">
                <div class="ApplyInputInside">
                  <p>Full Name</p>
                  <input bind:value={applyData.fullName}>
                </div>
                <div class="ApplyInputInside">
                  <p>Date Of Birth</p>
                  <input bind:value={applyData.date} type="date" style="text-align: center; padding-right: 0.5vw; padding-left: 0vw">
                </div>
                <div class="ApplyInputInside">
                  <p>Ever Worked At A Saloon?</p>
                  <select bind:value={applyData.workedBefore}>
                    <option value="no">No I Have Not</option>
                    <option value="yes">Yes I Did</option>
                  </select>
                </div>
                <div class="ApplyInputInside">
                  <p>Can You Work Full Time</p>
                  <select bind:value={applyData.fullTime}>
                    <option value="no">No, Part Time</option>
                    <option value="yes">Yes I Can</option>
                  </select>
                </div>
              </div>  
            </div>
          {/if}
          </div>
        <div class="MainButtons">
         
          {#if k == 'Book'} 
           
            <div class="MainButton" on:click={() => {buttonClick('submitBook')}}>
              <p>BOOK APPOINTMENT</p>
            </div>
            <div class="MainButton" on:click={() => {buttonClick('cancel')}}>
              <p>CANCEL APPOINTMENT</p>
            </div>
          {/if}
          {#if k == 'Main'} 
          <div class="MainButton" on:click={() => {buttonClick('book')}}>
            <p>BOOK APPOINTMENT</p>
          </div>
          <div class="MainButton" on:click={() => {buttonClick('checkAppointment')}}>
            <p>CHECK APPOINTMENT</p>
          </div>
          
        {/if}
            {#if k == 'Apply'} 
            <div class="MainButton" on:click={() => {buttonClick('submitApply')}}>
              <p>APPLY</p>
            </div>
            <div class="MainButton" on:click={() => {buttonClick('cancel')}}>
              <p>CANCEL</p>
            </div>
            
            {/if}
        </div>
        <div class="interested" on:click={() => {buttonClick('apply')}}>
          <p>Interested in working for us?<br><span style="cursor: pointer;font-weight: 900;text-decoration:underline">Click Here To Apply Now!</span></p>
        </div>
      </div>
    </div>

    </div>
    
  </div>
  
</main>