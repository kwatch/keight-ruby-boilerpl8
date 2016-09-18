# -*- coding: utf-8 -*-

$urlpath_mapping = [
  ['/'                             , "./app/action:My::TopPage"],
  ['/api', [
    ['/hello'                      , "./app/api/hello:HelloAPI"],
   #['/books'                      , "./app/api/books:BooksAPI"],
   #['/books/{book_id}/comments'   , "./app/api/books:BookCommentsAPI"],
   #['/orders'                     , "./app/api/orders:OrdersAPI"],
  ]],
  ['/admin', [
   #['/books'                      , "./app/admin/books:AdminBooksPage"],
   #['/orders'                     , "./app/admin/orders:AdminOrdersPage"],
  ]],
  ['/static'                       , "./app/action:My::StaticPage"],
  [''                              , "./app/action:My::PublicPage"],
]
