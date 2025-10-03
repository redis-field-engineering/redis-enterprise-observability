'use strict'

const computeRelativeUrlPath = require('../util/compute-relative-url-path')

function convertImageRef (resourceSpec, currentPage, contentCatalog, read) {
  const image = contentCatalog.resolveResource(resourceSpec, currentPage.src, 'image', ['image'])
  // technically, this should check for out instead of pub, but these properties are expected to be set together
  if (read) return image?.contents.toString()
  return image?.pub && computeRelativeUrlPath(currentPage.pub.url, image.pub.url)
}

module.exports = convertImageRef
