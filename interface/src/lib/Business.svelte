<script>
// @ts-nocheck

    import Check from "../assets/svgs/check.svelte";
    import SideBar from "./SideBar.svelte";
    import { chart } from "svelte-apexcharts";
    import { Businesspage , JobApplications , EmployeesList , JobGrades , BusinessEncomy , BusinessTargets} from '../Data'
    import nails from '../assets/nailspic.png'
    import AlertsManager from './alertsManager.svelte'
  import Withdraw from "../assets/svgs/withdraw.svelte";
    const monthNames = {
        "January": 1,
        "February": 2,
        "March": 3,
        "April": 4,
        "May": 5,
        "June": 6,
        "July": 7,
        "August": 8,
        "September": 9,
        "October": 10,
        "November": 11,
        "December": 12
    };

    let options = {}
    if($BusinessEncomy.length !== 0) {
        let ordered = {};
        Object.keys($BusinessEncomy.salesGraph).sort((a, b) => {
            return monthNames[a] - monthNames[b]
        }).forEach(function(key) {
            ordered[key] = $BusinessEncomy.salesGraph[key];
        });
        options = {
        chart: {
            toolbar: {show: false},
            type: "area",
            height: '90%',
            colors: ["#E27483", "#F8C300"]
        },
        dataLabels: {
            enabled: false
        },
   
        series: [
            {
                name: "sales",
                color: '#BB86FC',
                data:Object.values(ordered),
            },
        ],
        xaxis: {
            categories: Object.keys(monthNames),
        },
    };
    }
    let alertsActions 
    let payAllAmount


    $JobGrades[4] = 'Boss'
    $JobGrades[3] = 'Ceo'
    $JobGrades[2] = 'Worker'
    $JobGrades[1] = 'Caddy' 

    let businessWithdraw = 0


    let showJobApplication = false
    let ShowJobData = [{name: 'Error' , date: '1/1/1111' , workedBefore: 'no' , workfulltime: 'no'}]
    function ShowApplication(data) {
        ShowJobData[0].name = data.fullName
        ShowJobData[0].date = data.date
        ShowJobData[0].workedBefore = data.workedBefore
        ShowJobData[0].workfulltime = data.workFullTime
        showJobApplication = true
    }

    function HirePlayer(data) {
        fetch(`https://${GetParentResourceName()}/hirePlayer` , {method: 'POST' , body: JSON.stringify({data: data})}).then(d => d.json()).then(response => {
          alertsActions.addNotification(response.message , 'Nails')
          $JobApplications = $JobApplications.filter(e => e.cid !== data.cid)
          $EmployeesList.push(response.pData)
        })
    }

    function FireEmployee(cid) {
        // fetch
    }

    function PayAll() {
        fetch(`https://${GetParentResourceName()}/payAll` , {method: 'POST' , body: JSON.stringify({amount: payAllAmount})}).then(d => d.json()).then(response => {
          alertsActions.addNotification(response.message , 'Nails')
        })
    }

    function calcPercentage(target , current) {
        let a = (current / target) * 100
        if(a > 100) {
            return `+${(Math.floor(a) - 100)}%`
        } else {
            return `-${(100 - Math.floor(a))}%`
        }
        
    }

    function WithdrawC() {
        fetch(`https://${GetParentResourceName()}/withdrawCompany` , {method: 'POST' , body: JSON.stringify({amount: businessWithdraw})}).then(d => d.json()).then(response => {
          alertsActions.addNotification(response.message , 'Nails')
        })
    }
   
</script>
<div class="BusinessWarp">
    <div class="BusinessContainer">
        <div style="display: none">
            <AlertsManager bind:this={alertsActions}></AlertsManager>
        </div>
        <SideBar></SideBar>
        <div class="JobApplicationPop" style="display: {showJobApplication == true ? 'flex' : 'none'};">
            <p on:click={() => {showJobApplication = false}} style="position: absolute; right: 0; color: white; font-family: arial; margin-right: 1vw; font-size: 0.6vw; opacity: 0.6; margin-top: 1vw; cursor: pointer">X</p>
            <div style="width: 100%;" class="flexS">
                <p style="font-family: Cherish;font-size: 2.5vw;margin: 0;margin-top: 1vh;color:#302F2F">Job Application</p>
                <div class="Line" style="width: 90%;"></div>
            </div>
            <div class="Apply" >
                <div class="ApplyInputs">
                  <div class="ApplyInputInside">
                    <p>Full Name</p>
                    <input disabled value={ShowJobData[0].name}>
                  </div>
                  <div class="ApplyInputInside">
                    <p>Date Of Birth</p>
                    <input disabled value={ShowJobData[0].date} type="date" style="text-align: center; padding-right: 0.5vw; padding-left: 0vw">
                  </div>
                  <div class="ApplyInputInside">
                    <p>Ever Worked At A Saloon?</p>
                    <select value={ShowJobData[0].workedBefore} disabled>
                      <option value="no">No I Have Not</option>
                      <option value="yes">Yes I Did</option>
                    </select>
                  </div>
                  <div class="ApplyInputInside">
                    <p>Can You Work Full Time</p>
                    <select value={ShowJobData[0].workfulltime} disabled>
                      <option value="yes">Yes I Can</option>
                      <option value="no">No, Part Time</option>
                    </select>
                  </div>
                </div>  
              </div>
        </div>
        <div class="Insidebusiness">
            <div class="BusinessHeader">
                <p>Managemenet</p>
                <div class="Line" style="width: 31%;height: 0.35vh"></div>
            </div>
            <div class="BussinessStats">
                <div class="BusinessStatbox {calcPercentage($BusinessTargets['CheckedIN'] , $BusinessEncomy.checkedIn).includes('+') ? 'GreenClass' : 'RedClass'}" >
                    <div class="checkIcon">
                        <Check classD={calcPercentage($BusinessTargets['CheckedIN'] , $BusinessEncomy.checkedIn).includes('+') ? '#9AE4A7' : '#EF8F8F'}/>
                    </div>
                    <p>Checked In</p>
                    <h1>{$BusinessEncomy.checkedIn}</h1>
                    <p>{calcPercentage($BusinessTargets['CheckedIN'] , $BusinessEncomy.checkedIn)} of target</p>
                </div>
                <div class="BusinessStatbox {calcPercentage($BusinessTargets['Sales'] , $BusinessEncomy.businessSales).includes('+') ? 'GreenClass' : 'RedClass'}" >
                    <div class="checkIcon">
                        <Check classD={calcPercentage($BusinessTargets['Sales'] , $BusinessEncomy.businessSales).includes('+') ? '#9AE4A7' : '#EF8F8F'}/>
                    </div>
                    <p>Sales</p>
                    <h1>{$BusinessEncomy.businessSales}</h1>
                    <p>{calcPercentage($BusinessTargets['Sales'] , $BusinessEncomy.businessSales)} of target</p>
                </div>
                <div class="BusinessStatbox {calcPercentage($BusinessTargets['AvgMade'] , $BusinessEncomy.businessMade).includes('+') ? 'GreenClass' : 'RedClass'}" >
                    <div class="checkIcon">
                        <Check classD={calcPercentage($BusinessTargets['AvgMade'] , $BusinessEncomy.businessMade).includes('+') ? '#9AE4A7' : '#EF8F8F'}/>
                    </div>
                    <p>Avg made</p>
                    <h1>${$BusinessEncomy.businessMade}</h1>
                    <p>{calcPercentage($BusinessTargets['AvgMade'] , $BusinessEncomy.businessMade)} of target</p>
                </div>
                <div class="BusinessStatbox {calcPercentage($BusinessTargets['WeekMoney'] , $BusinessEncomy.businessWeekMade).includes('+') ? 'GreenClass' : 'RedClass'}" >
                    <div class="checkIcon">
                        <Check classD={calcPercentage($BusinessTargets['WeekMoney'] , $BusinessEncomy.businessWeekMade).includes('+') ? '#9AE4A7' : '#EF8F8F'}/>
                    </div>
                    <p>Week Made</p>
                    <h1>${$BusinessEncomy.businessWeekMade}</h1>
                    <p>{calcPercentage($BusinessTargets['WeekMoney'] , $BusinessEncomy.businessWeekMade)} of target</p>
                </div>
            </div>
            <div class="BusinessChart" style="z-index: 9;display: {$Businesspage == 'mainP' ? 'flex' : 'none'}">
                <div style="width: 100%;height:100%;padding: 1.4vw">
                <div class="ChartHeader">
                    <p style="margin: 0;">Sales Graph</p>
                    <p style="font-size: 0.7vw;margin: 0;opacity: 0.6">Estimate</p>
                </div>
                <div use:chart={options}  style="width: 100%;height: 100%"/>
                </div>
            </div>

           {#if $Businesspage == 'Withdraw'}
            <div class="BusinessInsidePage">
                <span style="display: flex;flex-direction: column; justify-content: center; align-items: center">
                    <h1 style="font-size: 2.08vw;margin: 0">Total Money</h1>
                    <p style="font-size: 1.25vw;color: #3B803A; margin: 0">${$BusinessEncomy.businessMoney}</p>
                </span>
                <input type="number" bind:value={businessWithdraw}>
                <div class="Bbutton" on:click={() => {WithdrawC()}}>
                    <p>WITHDRAW</p>
                </div>
            </div>
           {/if}
           {#if $Businesspage == 'Support'}
           <div class="BusinessInsidePage" style="gap: 0.9vh;">
              <p class="BusinessHeaderTitle">Contact Info</p>
              <input>
              <textarea></textarea>
              <div class="Bbutton">
                <p>SET NUMBER</p>
            </div>
           </div>
          {/if}
          {#if $Businesspage == 'JobApplications'}
          <div class="BusinessInsidePage" style="gap: 0.9vh;">
             <p class="BusinessHeaderTitle">Job Applications</p>
             <div class="EmployeesMng">
                <div class="flexS" style="gap: 0.5vh;width: 100%">
                    <div class="EmployeeList">
                        {#each $JobApplications as data}
                            <div class="EmployeeUser">
                                <span class="flexS" style="flex-direction: row;">
                                    <img src={nails}>
                                    <p>{data.fullName}</p>
                                </span>
                                <select style="width: 5.9vw;background-color: transparent;color: #CECECE" bind:value={data.payment}>
                                    <option value="200">200</option>
                                    <option value="500">500</option>
                                    <option value="800">800</option>
                                    <option value="1200">1200</option>
                                    <option value="2000">2000</option>
                                </select>
                                <select style="width: 3vw;background-color: transparent;color: #CECECE" bind:value={data.gradeNumber}>
                                    <option value={1}>1</option>
                                    <option value={2}>2</option>
                                    <option value={3}>3</option>
                                    <option value={4}>4</option>
                                </select>
                                <div class="flexS" style="flex-direction: row; gap: 0.5vw">
                                    <button style="background-color: #00A3FF1A" on:click={() => {ShowApplication(data)}}>INFO</button>
                                    <button style="background-color: #3B803A;" on:click={() => {HirePlayer(data)}}>HIRE</button>
                                    <button>DENY</button>
                                </div>
                            </div>
                        {/each}
                    </div>

                </div>
            </div>
          </div>
         {/if}
          {#if $Businesspage == 'Employees'}
          <div class="BusinessInsidePage" style="gap: 0.9vh;justify-content: center;">
            <p class="BusinessHeaderTitle">Employee's</p>
            <div class="EmployeesMng" style="align-items: start">
                <div class="flexS" style="gap: 0.5vh;">
                    <select style="width: 6.9vw;background-color: transparent;color: #CECECE" bind:value={payAllAmount}>
                        <option value="200">200</option>
                        <option value="500">500</option>
                        <option value="800">800</option>
                        <option value="1200">1200</option>
                        <option value="2000">2000</option>
                    </select>
                    <div class="Bbutton" style="width: 7.5vw;" on:click={() => {PayAll()}}>
                        <p>PAY ALL</p>
                    </div>
                </div>
                <div class="flexS" style="gap: 0.5vh;width: 80%">
                    <div class="EmployeeList">
                            {#each $EmployeesList as data}
                                <div class="EmployeeUser">
                                    <span class="flexS" style="flex-direction: row;">
                                        <img src={nails}>
                                        <p>{data.name}</p>
                                    </span>
                                    <select style="width: 5.9vw;background-color: transparent;color: #CECECE" bind:value={$JobGrades[data.gradeNumber]} disabled>
                                       <option value="Boss">Boss</option>
                                       <option value="Ceo">Ceo</option>
                                       <option value="Worker">Worker</option>
                                       <option value="Caddy">Caddy</option>

                                    </select>
                                    <select style="width: 3.9vw;background-color: transparent;color: #CECECE"  bind:value={data.payment}>
                                        <option value={200}>200</option>
                                        <option value={500}>500</option>
                                        <option value={800}>800</option>
                                        <option value={1200}>1200</option>
                                        <option value={2000}>2000</option>
                                    </select>
                                    <select style="width: 3vw;background-color: transparent;color: #CECECE" bind:value={data.gradeNumber}>
                                        <option value={1}>1</option>
                                        <option value={2}>2</option>
                                        <option value={3}>3</option>
                                        <option value={4}>4</option>
                                    </select>
                                    <button on:click={() => {FireEmployee(data.cid)}}>Fire</button>
                                </div>
                            {/each}
                       
                    </div>
                </div>
            </div>
          </div>
         {/if}
        </div>
    </div>
</div>