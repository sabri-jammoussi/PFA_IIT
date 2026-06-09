<script setup>
import { RouterView } from 'vue-router'
</script>

<template>
  <!-- Global Toast Notifications -->
  <PToast position="top-right" />
  
  <!-- Active Route View -->
  <RouterView />
</template>
