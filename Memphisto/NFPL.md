# NFPL - Network Formatted Page Language
NFPL is a special web page language for OpenComputers which is adapted to the peculiarities of computers from this mod.  
Written by [Bs0Dd](https://github.com/Bs0Dd).  
Actual version: **0.0.2** (07.03.2021)
## Page structure  
NFPL page (*.nfp) - lua serialized array containing page parameters and objects.  
For example:
```lua
{ label= 'Welcome to Compys Website', background= 0x787878,
{ 'text', 2, 2, 0x00FF00, "DEF", "Welcome to Compys Website - The first on-line page for OpenComputers"},
{ 'link', 3, 4, 0xFFFFFF, 0x0000FF, "Next page", "../pagefile.nfp"},
{ 'text', 4, 6, {
	{0xFFFFFF, 0xCC0000, "That's one small ste"},
	{0xFFFFFF, 0x00B600, "p for a man, one gia"},
	{0xFFFFFF, 0x0024FF, "nt leap for mankind."}}},
{ 'border', 1, 38, 63, 0x00FFFF, "DEF", 'dpseudo'},
{ 'image', 65, 4, "../pics/github.pic"} }
```
All parameters are variables, and all objects are tables with object parameters.
## Object types and examples
### Page parameters
`label` - defines a name for a page. It will be shown next to the address.  
![Page label](https://i.imgur.com/DKDD0nN.png)  
	
`background` - custom background page color, else using standart color from Browser's config.

Both parameters are optional and can be absent in the page.
### Page content
Сolor is sets by value **0xRRGGBB**.  
Also, instead of it, you can use the "DEF" value to use the color under the object.  
In all paths ".." means a root of site.
#### Text 
`{'text', x, y, foreground, background, string, [transparency]}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| *string* | text | Text |
| [*float* [0.0; 1.0] | transparency] | Optional text transparency |  

![Text demo](https://i.imgur.com/eEEbbS6.png) 

If you need to use different colors in a row, you can use the following styling:
```
{'text', x, y, {
{foreground, background, string, [transparency]},
{foreground, background, string, [transparency]},
{foreground, background, string, [transparency]}}}
```
#### Hyperlink
`{'link', x, y, foreground, background, string, path, [transparency]}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| *string* | text | Text |
| *string* | path | Path to page |
| [*float* [0.0; 1.0] | transparency] | Optional link transparency |  

Looks like text object but navigates to the page on click.
#### Download link
`{'dlink', x, y, foreground, background, string, path, [transparency]}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| *string* | text | Text |
| *string* | path | Path to file |
| [*float* [0.0; 1.0] | transparency] | Optional link transparency |  

Looks like text object but starts file downloading on click.
#### Image
`{'image', x, y, picpath}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *string* | picpath | Path to picture |  

Supports only OCIF5, OCIF6 and OCIF7 pictures.  
Converter is [here](https://github.com/IgorTimofeev/OCIFImageConverter).

![Images demo](https://i.imgur.com/aDfnjtb.png) 
#### Image-hyperlink
`{'ilink', x, y, foreground, background, picpath, path`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| *string* | picpath | Path to picture |
| *string* | path | Path to page |

Looks like image object but navigates to the page on click.
#### Download image-link
`{'idlink', x, y, foreground, background, picpath, path}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| *string* | picpath | Path to picture |
| *string* | path | Path to file |

Looks like image object but starts file downloading on click.
#### Border
`{'border', x, y, length, foreground, background, style, [transparency]}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *int* | length | Border length |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| *string* | style | The symbol that will fill the border or style name |
| [*float* [0.0; 1.0] | transparency] | Optional border transparency |  

Available styles: `dash`, `equal`, `pseudo`, `dpseudo`.  
![Borders demo](https://i.imgur.com/F9V4hkb.png)
#### Frame
`{'frame', x, y, length, foreground, background, style, content, [transparency]}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *int* | length | Border length |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| *table* or *string* | style | The symbols will used by the frame or style name |
| *table* | content | The rows content |
| [*float* [0.0; 1.0] | transparency] | Optional frame transparency |  

Available styles: `dash`, `equal`, `pseudo`, `dpseudo`.  
You can set custom frame by specifying instead of a string with a style an array of the form:  
`{u.l.edge, h.sides, u.r.edge, d.l.edge, v.sides, d.r.edge, n.p.sides}`.  

On example custom styles are `{'◢','█','◣','◥','█','◤', true}` and `{'<','<>','>','<','|','>', false}`.  
![Frames demo](https://i.imgur.com/w872bqR.png)  

You can use both row define styles like text object:  
```
{'frame', x, y, length, foreground, background, style,
{{foreground, background, string, [transparency]},
{foreground, background, string, [transparency]}},
[transparency]}
```
or  
```
{'frame', x, y, length, foreground, background, style,
{{{foreground, background, string, [transparency]},{foreground, background, string, [transparency]}},
{{foreground, background, string, [transparency]},{foreground, background, string, [transparency]}}},
[transparency]}
```
#### Semi-pixel
`{'semipixel', x, y, color}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x1 | Coordinate by X-axis |
| *int* | y1 | Coordinate by Y-axis |
| *int* | color | Pixel color |

Draws a semi-pixel. Note that for semi-pixels, the Y coordinate is twice as large as the real one.
#### Rectangle
`{'rectangle', x, y, width, height, foreground, background, semipixel, symbol, [transparency]}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *int* | width | Rectangle width |
| *int* | height | Rectangle height |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| [*boolean* | semipixel] | Draw semi-pixel rectangle |
| [*string* | symbol] | The symbol that will fill the rectangle |
| [*float* [0.0; 1.0] | transparency] | Optional background transparency |  

When drawing a semi-pixel rectangle, the variables symbol and transparency are ignored.  
![Rectangle demo](https://i.imgur.com/vxd8Wf5.png)
#### Line
`{'line', x1, y1, x2, y2, foreground, background, semipixel, symbol}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x1 | First point coordinate by X-axis |
| *int* | y1 | First point coordinate by Y-axis |
| *int* | x2 | Second point coordinate by X-axis |
| *int* | y2 | Second point coordinate by Y-axis |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| [*boolean* | semipixel] | Draw semi-pixel line |
| [*string* | symbol] | The symbol that will fill the line |

When drawing a semi-pixel line, the symbol variable are ignored.  
![Line demo](https://i.imgur.com/EMjDmeL.png)
#### Ellipse
`{'ellipse', x, y, radiusX, radiusY, foreground, background, semipixel, symbol}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *int* | x | X coordinate |
| *int* | y | Y coordinate |
| *int* | radiusX | Ellipse radius by X-axis |
| *int* | radiusY | Ellipse radius by Y-axis |
| *int* | foreground | Foreground color |
| *int* | background | Background color |
| [*boolean* | semipixel] | Draw semi-pixel ellipse |
| [*string* | symbol] | The symbol that will fill the ellipse |  

When drawing a semi-pixel ellipse, the symbol variable are ignored.  
![Ellipse demo](https://i.imgur.com/k1F7eea.png)
#### Bezier curve
`{'curve', points, color, accuracy}`
| Type | Parameter | Description |
| ------ | ------ | ------ |
| *table* | points | Table with structure ```{{x, y}, {x, y}, {x, y}}``` that contains a set of points for drawing curve |
| *int* | color | Curve color |
| *float* | accuracy | Curve accuracy. Less = more accurate |  

![Curve demo](https://i.imgur.com/XASgwcj.png)
