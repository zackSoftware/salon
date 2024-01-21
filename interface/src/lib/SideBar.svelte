<script>
   
    import HairSVG from './hair.svelte'

    import CheckIN from '../assets/svgs/checkin.svelte'
    import Checkout from '../assets/svgs/checkout.svelte';
    import Withdraw from '../assets/svgs/withdraw.svelte';
    import Employees from '../assets/svgs/employees.svelte';
    import Support from '../assets/svgs/support.svelte';
    import Stocks from '../assets/svgs/stocks.svelte';
    import { Businesspage , Page } from '../Data'


    function Check(type) {
      fetch(`https://${GetParentResourceName()}/check` , {method: 'POST' , body: JSON.stringify(type =  type)})
    }
</script>
<div class="SidebarContainer">
    <div class="HeaderImage" style="z-index: 9;" on:click={() => {$Businesspage = 'mainP'}}>
      <HairSVG/>
    </div>
    <div class="SidebarButtons">
        <div on:click={() => {Check('in')}}>
          <div >
            <CheckIN></CheckIN>
          </div>
          
          <p>Check In</p>
        </div>
        <div on:click={() => {Check('out')}}>
          <div >
            <Checkout/>
          </div>
          
          <p>Check Out</p>
        </div>
        <div on:click={() => {$Businesspage = 'Withdraw'}}>
          <div>
            <Withdraw/>
          </div>
          
          <p>Withdraw</p>
        </div>
        <div on:click={() => {$Businesspage = 'Employees'}}>
          <div >
            <Employees/>
          </div>
          
          <p>Employees</p>
        </div>
        <div on:click={() => {$Businesspage = 'JobApplications'}}>
          <div >
            <Employees/>
          </div>
          
          <p>Job Applications</p>
        </div>
        <!-- <div on:click={() => {$Businesspage = 'Support'}}>
          <div >
            <Support/>
          </div>
          
          <p>Support</p>
        </div> -->
        <div on:click={() => {$Page = 'Stocks'}}>
          <div >
            <Stocks/>
          </div>
          
          <p>Stocks</p>
        </div>
    </div>
</div>