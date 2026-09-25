<script def>
{
  "description": "Five-second recording test: verify that the custom transparent AIUI greeting appears over the real first-person camera scene with microphone audio.",
  "schema": { "data": { "type": "object", "properties": {} } }
}
</script>

<script setup>
export default { data: {} };
</script>

<page class="smoke">
  <text class="greeting">中秋快乐</text>
</page>

<style>
.smoke {
  width: 100%;
  height: 100%;
  background-color: transparent;
  color: #59ff78;
}
.greeting {
  position: absolute;
  top: 150px;
  left: 50%;
  width: 190px;
  margin-left: -95px;
  text-align: center;
  font-size: 20px;
  line-height: 30px;
}
</style>
