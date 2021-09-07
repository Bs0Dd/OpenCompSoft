# NyaDraw Graphic Engine

Standalone "Screen.lua" port from MineOS to OpenOS

Made by [ECS](https://github.com/IgorTimofeev)  
Port by [Bs0Dd](https://github.com/Bs0Dd)

## Download

* `pastebin get CsY9HpHB /usr/lib/NyaDraw.lua` to load a standard version of library (34Kb)


* `pastebin get PqqutTfX /usr/lib/NyaDrMini.lua` to load a minified (but full-functional) version of library (14Kb)

## API (based on ECS's docs)

| Contents |
| ----- |
| [Main methods:](#main-methods) |
| [   engine.getResolution](#enginegetresolution-int-width-int-height) |
| [   engine.setResolution](#enginesetresolution-width-height-) |
| [   engine.setGPUProxy](#enginesetgpuproxy-proxy-) |
| [   engine.getGPUProxy](#enginegetgpuproxy-table-proxy) |
| [   engine.bind](#enginebind-address-) |
| [   engine.loadImage](#engineloadimage-path--table-picture) |
| [Rendering methods:](#rendering-methods) |
| [   engine.update](#engineupdate-force-) |
| [   engine.setDrawLimit](#enginesetdrawlimit-x1-y1-x2-y2-) |
| [   engine.getDrawLimit](#enginegetdrawlimit-int-x1-int-y1-int-x2-int-y2) |
| [   engine.copy](#enginecopy-x-y-width-height--table-pixeldata) |
| [   engine.paste](#enginepaste-x-y-pixeldata-) |
| [   engine.set](#enginepaste-x-y-pixeldata-) |
| [   engine.get](#enginepaste-x-y-pixeldata-) |
| [   engine.drawRectangle](#enginedrawrectangle-x-y-width-height-background-foreground-symbol-transparency-) |
| [   engine.clear](#engineclear-color-transparency-) |
| [   engine.drawText](#enginedrawtext-x-y-color-text-transparency-) |
| [   engine.drawImage](#enginedrawimage-x-y-picture-) |
| [   engine.drawLine](#enginedrawline-x1-y1-x2-y2-background-foreground-symbol-) |
| [   engine.drawEllipse](#enginedrawellipse-centerx-centery-radiusx-radiusy-background-foreground-symbol-) |
| [Semi-pixel rendering methods:](#semi-pixel-rendering-methods) |
| [   engine.semiPixelSet](#enginesemipixelset-x-y-color-) |
| [   engine.drawSemiPixelRectangle](#enginedrawsemipixelrectangle-x-y-width-height-color-) |
| [   engine.drawSemiPixelLine](#enginedrawsemipixelline-x1-y1-x2-y2-color-) |
| [   engine.drawSemiPixelEllipse](#enginedrawsemipixelellipse-centerx-centery-radiusx-radiusy-color-) |
| [   engine.drawSemiPixelCurve](#enginedrawsemipixelcurve-points-color-accuracy-) |
| [Auxiliary methods:](#auxiliary-methods) |
| [   engine.flush](#engineflush-width-height-) |
| [   engine.getIndex](#enginegetindex-x-y--int-index) |
| [   engine.rawSet](#enginerawset-index-background-foreground-symbol-) |
| [   engine.rawGet](#enginerawget-index--int-background-int-foreground-string-symbol) |
| [   engine.getCurrentFrameTables](#enginegetcurrentframetables-table-currentframebackgrounds-table-currentframeforegrounds-table-currentframesymbols) |
| [   engine.getNewFrameTables](#enginegetnewframetables-table-newframebackgrounds-table-newframeforegrounds-table-newframesymbols) |
| [Practical example](#practical-example) |

### Main methods

engine.**getResolution**(): *int* width, *int* height
-----------------------------------------------------------
Get screen buffer resolution. There's also engine.**getWidth**() and engine.**getHeight**() methods for your comfort.

engine.**setResolution**( width, height )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | width | Screen buffer width |
| *int* | height | Screen buffer height |

Set screen buffer and GPU resolution. Content of buffer will be cleared with black pixels and whitespace symbol.

engine.**setGPUProxy**( proxy )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *table* | proxy | Proxy table to GPU card |

Sets the GPU component proxy is used by library to given one. Content of buffer will be cleared with black pixels and whitespace symbol.

engine.**getGPUProxy**(): *table* proxy
-----------------------------------------------------------
Get a pointer to currently bound GPU component proxy.

engine.**bind**( address )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *string* | address | GPU component address |

Set the GPU component address is used by library. Content of buffer will be cleared with black pixels and whitespace symbol.

engine.**loadImage**( path ): *table* picture
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *string* | path | Path to the picture to be loaded |

Loads a OCIF picture at the specified path and returns it as a table for, for example, drawing through engine.**drawImage**(...). Supports OCIF5-8 formats.

### Rendering methods

engine.**update**( [force] )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| [*boolean* | force] | Force content drawing |

Checks of what pixels need to be drawn and draws them on screen. If optional argument **force** is specified, then the contents of screen buffer will be drawn completely and regardless of the changed pixels.

engine.**setDrawLimit**( x1, y1, x2, y2 )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x1 | First point coordinate of draw limit by x-axis |
| *int* | y1 | First point coordinate of draw limit by y-axis |
| *int* | x2 | Second point coordinate of draw limit by x-axis |
| *int* | y2 | Second point coordinate of draw limit by y-axis |

Set buffer draw limit to the specified values. In this case, any operations that go beyond the limits will be ignored. By default, the buffer always has a drawing limit in the ranges **x ∈ [1; buffer.width]** and **y ∈ [1; buffer.height]** 

engine.**getDrawLimit**(): *int* x1, *int* y1, *int* x2, *int* y2
-----------------------------------------------------------
Get currently set draw limit

engine.**copy**( x, y, width, height ): *table* pixelData
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | Copied area coordinate by x-axis |
| *int* | y | Copied area coordinate by y-axis |
| *int* | width | Copied area width |
| *int* | height | Copied area height |

Copy content of specified area from screen buffer and return it as a table. Later it can be used with engine.**paste**(...).

engine.**paste**( x, y, pixelData )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | Paste coordinate by x-axis |
| *int* | y | Paste coordinate by y-axis |
| *table* | pixelData | Table with copied screen buffer data |

Paste the copied contents of screen buffer to the specified coordinates.

engine.**set**( x, y, background, foreground, symbol )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | Screen coordinate by x-axis |
| *int* | y | Screen coordinate by x-axis |
| *int* | background | Background color |
| *int* | foreground | Text color |
| *string* | symbol | Symbol |

Set value of specified pixel on screen.

engine.**get**( x, y ): *int* background, *int* foreground, *string* symbol
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | Screen coordinate by x-axis |
| *int* | y | Screen coordinate by x-axis |

Get value of specified pixel on screen.

engine.**drawRectangle**( x, y, width, height, background, foreground, symbol, transparency )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | Rectangle coordinate by x-axis |
| *int* | y | Rectangle coordinate by x-axis |
| *int* | width | Rectangle width |
| *int* | height | Rectangle height |
| *int* | background | Rectangle background color |
| *int* | foreground | Rectangle text color |
| *string* | symbol | The symbol that will fill the rectangle |
| [*float* [0.0; 1.0] | transparency] | Optional background transparency |

Fill the rectangular area with the specified pixel data. If optional transparency parameter is specified, the rectangle will "cover" existing pixel data, like a glass.

engine.**clear**( [color, transparency] )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| [*int* | background] | Optional background color |
| [*float* [0.0; 1.0] | transparency] | Optional background transparency |

It works like engine.**drawRectangle**(...), but it applies immediately to all the pixels in the buffer. If arguments are not passed, then the buffer is filled with the standard black color and the whitespace symbol.

engine.**drawText**( x, y, color, text, transparency )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | Text coordinate by x-axis |
| *int* | y | Text coordinate by y-axis |
| *int* | foreground | Text color |
| *string* | text | Text |
| [*float* [0.0; 1.0] | transparency] | Optional text transparency |

Draw the text of the specified color. The background color under text will remain the same. It is also possible to set the transparency of the text.

engine.**drawImage**( x, y, picture )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | Image coordinate by x-axis |
| *int* | y | Image coordinate by y-axis |
| *table* | picture | Loaded image |

Draw image that was loaded earlier via engine.**loadImage**(...) method. The alpha channel of image is also supported.

engine.**drawLine**( x1, y1, x2, y2, background, foreground, symbol )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x1 | First point coordinate by x-axis |
| *int* | y1 | First point coordinate by y-axis |
| *int* | x2 | Second point coordinate by x-axis |
| *int* | y2 | Second point coordinate by y-axis |
| *int* | background | Line background color |
| *int* | foreground | Line foreground color |
| *string* | symbol | Line symbol |

Draw a line with specified pixel data from first point to second.

engine.**drawEllipse**( centerX, centerY, radiusX, radiusY, background, foreground, symbol )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | centerX | Ellipse middle point by x-axis |
| *int* | centerY | Ellipse middle point by y-axis |
| *int* | radiusX | Ellipse radius by x-axis |
| *int* | radiusY | Ellipse radius by y-axis |
| *int* | background | Ellipse background color |
| *int* | foreground | Ellipse foreground color |
| *string* | symbol | Ellipse symbol |

Draw ellipse with specified pixel data.

### Semi-pixel rendering methods

All semi-pixel methods allow to avoid the effect of doubling pixel height of the console pseudographics using special symbols like "▄". In this case, the transmitted coordinates along the **Y** axis must belong to the interval **[0; buffer.height * 2]**.

engine.**semiPixelSet**( x, y, color )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x1 | Coordinate by x-axis |
| *int* | y1 | Coordinate by y-axis |
| *int* | color | Pixel color |

Set semi-pixel value in specified coordinates.

engine.**drawSemiPixelRectangle**( x, y, width, height, color )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | Rectangle coordinate by x-axis |
| *int* | y | Rectangle coordinate by y-axis |
| *int* | width | Rectangle width |
| *int* | height | Rectangle height |
| *int* | color | Rectangle color |

Draw semi-pixel rectangle.

engine.**drawSemiPixelLine**( x1, y1, x2, y2, color )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x1 | First point coordinate by x-axis |
| *int* | y1 | First point coordinate by y-axis |
| *int* | x2 | Second point coordinate by x-axis |
| *int* | y2 | Second point coordinate by y-axis |
| *int* | color | Line color |

Rasterize a semi-pixel line witch specified color.

engine.**drawSemiPixelEllipse**( centerX, centerY, radiusX, radiusY, color )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | centerX | Ellipse middle point by x-axis |
| *int* | centerY | Ellipse middle point by y-axis |
| *int* | radiusX | Ellipse radius by x-axis |
| *int* | radiusY | Ellipse radius by y-axis |
| *int* | color | Ellipse color |

Draw semi-pixel ellipse with specified color.

engine.**drawSemiPixelCurve**( points, color, accuracy )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *table* | points | Table with structure ```{{x = 32, y = 2}, {x = 2, y = 2}, {x = 2, y = 98}}``` that contains a set of points for drawing curve |
| *int* | color | Curve color |
| *float* | accuracy | Curve accuracy. Less = more accurate |

Draw the [Bezier Curve](https://en.wikipedia.org/wiki/B%C3%A9zier_curve) with specified color

### Auxiliary methods

The following methods are used by the library itself or by applications that require maximum performance and calculate the pixel data of the buffer manually. In most cases, they do not come in handy, but they are listed *just in case*.

engine.**flush**( [width, height] )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | width | New screen buffer width |
| *int* | height | New screen buffer width |

Set screen buffer resolution to the specified one and fill it with black pixels and whitespace stringacter. Unlike buffer.**setResolution**() it does not change the current resolution of the GPU. If optional arguments are **not specified**, then the buffer size becomes equivalent to the current GPU resolution.

engine.**getIndex**( x, y ): **int** index
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | Screen coordinate by x-axis |
| *int* | y | Screen coordinate by y-axis |

Convert screen coordinates to the screen buffer index. For example, a **2x1** pixel has a buffer index equals **4**, and a pixel of **3x1** has a buffer index equals **7**.

engine.**rawSet**( index, background, foreground, symbol )
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | index | Screen buffer index |
| *int* | background | Background color |
| *int* | foreground | Text color |
| *string* | symbol | Symbol |

Set specified data values to pixel with specified index.

engine.**rawGet**( index ): **int** background, **int** foreground, **string** symbol
-----------------------------------------------------------
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | index | Screen buffer index |

Get data values of pixel with specified index.

engine.**getCurrentFrameTables**(): **table** currentFrameBackgrounds, **table** currentFrameForegrounds, **table** currentFrameSymbols
-----------------------------------------------------------

Get current screen buffer frames (that is displayed on screen) that contains pixel data. This method is used in rare cases where maximum performance and manual buffer changing pixel-by-pixel is required.

engine.**getNewFrameTables**(): **table** newFrameBackgrounds, **table** newFrameForegrounds, **table** newFrameSymbols
-----------------------------------------------------------

Works like engine.**getCurrentFrameTables**(), but returns frames that user is changing in realtime (before calling buffer.**drawChanges**())

### Practical example

```lua
-- Import libarary
local engine = require("NyaDraw")

-- Set GPU for working
engine.setGPUProxy(require("component").gpu)

--------------------------------------------------------------------------------

-- Load image from file and draw it to screen engine
engine.drawImage(1, 1, engine.loadImage("/Keyboard.pic"))
-- Fill engine with black color and transparency set to 0.6 to make image "darker"
engine.clear(0x0, 0.6)

-- Draw 10 rectangles filled with random color
local x, y, xStep, yStep = 2, 2, 4, 2
for i = 1, 10 do
	engine.drawRectangle(x, y, 6, 3, math.random(0x0, 0xFFFFFF), 0x0, " ")
	x, y = x + xStep, y + yStep
end

-- Draw yellow semi-pixel ellipse
engine.drawSemiPixelEllipse(22, 22, 10, 10, 0xFFDB40)
-- Draw white semi-pixel line
engine.drawSemiPixelLine(2, 36, 35, 3, 0xFFFFFF)
-- Draw green bezier curve with accuracy set to 0.01
engine.drawSemiPixelCurve(
	{
		{ x = 2, y = 63},
		{ x = 63, y = 63},
		{ x = 63, y = 2}
	},
	0x44FF44,
	0.01
)

-- Draw changed pixels on screen
engine.update()
```

Result: 

![Example](https://i.imgur.com/ISIdpu8.png)
