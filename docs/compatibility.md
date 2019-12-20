
# Compatibility Recommendations

If you want to make your code fully compatible and interoperable with other Smalltalk dialects you must restrict yourself to the minimum support provided by Tonel.  

## Application hierarchy

It is recommended you only use  _Applications_ **without** _SubApplications_, so the mapping _Application_ (VAST) ->_Package_ (Tonel) will be straightforward in both directions.

You could use _SubApplications_ that will be read as _Packages_ in other dialects, but that _hierarchy_ information is going to be lost if the other dialect writes it back to Tonel format. This is so because the "metadata" we use to store the parent application, the config expressions, etc. is not read by other dialects and discarded once written back.

E.g.
1. You have the VAST Application named `MyCoolApp` with `MyCoolSubappA` and `MyCoolSubAppB`
2. You write them to disk using the Tonel Writer
3. You load them into Pharo, they will be imported as three separate _Packages_ `MyCoolApp`, `MyCoolSubappA` and `MyCoolSubAppB` with no specific load order.
4. Assuming everything loaded correctly, you make some changes in Pharo and write them back to a Tonel repository.
5. Back in VAST you load from that Tonel repository
6. Regardless of the names, `MyCoolApp`, `MyCoolSubappA` and `MyCoolSubAppB` will be read as separate _Applications_ because in step 4 no metadata was written about `#vaSubapplications` nor `#vaParent`.

## Method Visibility

For the same reasons as in the Application Hierarchy, all methods should have `public` visibility.
