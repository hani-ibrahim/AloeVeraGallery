<p align="center">
<img width="600" height="450" src="Resources/title.png">
</p>

## UICollectionView with simple paging and rotation support

Main Componenets
- `PagedCollectionView`
    - Uses `PagedCollectionViewLayout` to layout the cells during rotation.
    - Adds the `UICollectionView` inside a `UIView` to enable the paging support.
- `PagedCollectionViewLayout`
    - Arrange the items to be displayed in full collection view size and adjust its size during rotation.
    - <b>Available customizations</b>:
        - `pageSpacing: CGFloat`: Spacing between the pages that is only visible during scrolling
        - `pageInset: UIEdgeInsets`: The insets for each individual page
        - `collectionViewInset: UIEdgeInsets`: Insets for the collection view area that is not visible, helpful when the collection view size is bigger than its superview. Used to enable paging support with spaces between pages.
        - `shouldRespectAdjustedContentInset: Bool`: When set to `false` -> the items will fill the whole available space
        - `scrollDirection: UICollectionView.ScrollDirection`: The direction of scrolling `horizontal` or `vertical`
        <br><br>
    <img width="600" height="520" src="Resources/paged-example.gif">
- `CenteredItemCollectionViewFlowLayout`
    - Scrolls the collectionView during rotation to show the same item that was visible before rotation
    - <b>Available customizations</b> (Check `CenteredItemLocatingDelegate`):
        - Center of the collection view
        - Cells to exclude during calculation
        - Ability to reject scrolling
        <br><br>
    <img width="600" height="520" src="Resources/centered-item-example.gif">

## DataSource (not required to use `PagedCollectionView`)
Handy classes to provide a data source for a collection view
Just create an instance of `SectionConfigurator` with the `ViewModels` and asign the dataSource to the collection view

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
