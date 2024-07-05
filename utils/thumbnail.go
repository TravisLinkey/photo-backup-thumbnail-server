package utils

import (
  "image"

  "github.com/nfnt/resize"
)

func CreateThumbnail(img image.Image) image.Image {
  return resize.Thumbnail(100, 100, img, resize.Lanczos3)
}
