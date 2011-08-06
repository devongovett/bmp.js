###
# MIT LICENSE
# Copyright (c) 2011 Devon Govett
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this 
# software and associated documentation files (the "Software"), to deal in the Software 
# without restriction, including without limitation the rights to use, copy, modify, merge, 
# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
# to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or 
# substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

class BMP
    @load: (url, callback) ->
        xhr = new XMLHttpRequest
        xhr.open("GET", url, true)
        xhr.responseType = "arraybuffer"
        xhr.onload = =>
            data = new Uint8Array(xhr.response or xhr.mozResponseArrayBuffer)
            callback new BMP(data)
            
        xhr.send(null)
    
    constructor: (@data) ->
        @pos = 0
        
        magic = (String.fromCharCode @data[@pos++] for i in [0...2]).join('')
        throw 'Invalid BMP file.' unless magic is 'BM'
        
        fileSize = @readUInt32()
        @pos += 4 # skip reserved values
        
        offset = @readUInt32()
        headerLength = @readUInt32()
        
        @width = @readUInt32()
        @height = @readUInt32()
        @colorPlaneCount = @readUInt16()
        @bitsPerPixel = @readUInt16()
        @compressionMethod = @readUInt32()
        @rawSize = @readUInt32()
        @hResolution = @readUInt32()
        @vResolution = @readUInt32()
        @paletteColors = @readUInt32()
        @importantColors = @readUInt32()
        
    readUInt16: ->
        b1 = @data[@pos++]
        b2 = @data[@pos++] << 8
        b1 | b2
        
    readUInt32: ->
        b1 = @data[@pos++]
        b2 = @data[@pos++] << 8
        b3 = @data[@pos++] << 16
        b4 = @data[@pos++] << 24
        b1 | b2 | b3 | b4
        
    copyToImageData: (imageData) ->
        data = imageData.data
        w = @width
        
        for y in [@height - 1...0]
            for x in [0...w]
                i = (x +  y * w) * 4
                b = @data[@pos++]
                g = @data[@pos++]
                r = @data[@pos++]
                data[i++] = r
                data[i++] = g
                data[i++] = b
                data[i++] = 255
                
        return
        
window.BMP = BMP