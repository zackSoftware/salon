<script>
    export let notifData

    import handAlert from '../assets/handalert.png'
    import hairAlert from '../assets/hairalert.png'

    setTimeout(() => {
        let element = document.getElementById(notifData.id)
        element.style.animation = 'slideOUT 0.4s forwards ease-in-out'
        setTimeout(() => {
            element.remove();
        }, 500);
    }, notifData.time);
</script>

<div class="Notify" id={notifData.id}>
    {#if notifData.type == 'Nails'}
        <img src={handAlert}>
    {/if}
    {#if notifData.type == 'Hair'}
        <img src={hairAlert}>
    {/if}
    <h1 class="notifyText">{@html notifData.text}</h1>
</div>