output image_id {
  value = local.image_id
}

# Helpful for debugging purposes
output userdata {
  value = base64encode(local.userdata)
}
