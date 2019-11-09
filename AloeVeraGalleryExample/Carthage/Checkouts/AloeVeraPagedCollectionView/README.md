<p align="center">
<img width="600" height="450" src="Resources/title.png">
</p>

## Collection view Layout with simple paging and rotation support

There are two CollectionViewFlowLayout:
- `CenteredItemCollectionViewFlowLayout`
    - Scrolls the collectionView during rotation to show the same item that was visible before rotation
    - <b>Available customizations</b> (Check `CenteredItemLocatorDelegate`):
        - Center of the collection view
        - Cells to exclude during calculation
        - Ability to reject scrolling
        <br><br>
    <img width="600" height="520" src="Resources/centered-item-example.gif">
- `PagedCollectionViewFlowLayout`
    - Scales the cells during rotation so they always cover the whole page.
    - <b>Available customizations</b>: (Check `PagedCollectionViewFlowLayout`)
        - Set page insets for each page
        - Set spacing between page that is only visible during scrolling
        - Decide whether the cells are displayed full screen or inside the safe Area region
        <br><br>
    <img width="600" height="520" src="Resources/paged-example.gif">


# License
MIT License

Copyright (c) 2019 Hani Ibrahim

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
