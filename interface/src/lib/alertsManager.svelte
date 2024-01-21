<script>
    import Alert from "./Alert.svelte";

    import { notifies } from "../Data.js";

    export function addNotification(text , type , time) {
        if(type === undefined) {
            type = 'Nails'
        }
        if(time === undefined) {
            time = 2000
        }
        notifies.update(items => {
            items.push({text: text, id: $notifies.length + 1 , type: type , time : time})
            return items
        })
    }
</script>

<div class="notifications">
    {#each  $notifies as data}
        <Alert notifData = {data}></Alert>
    {/each}
</div>