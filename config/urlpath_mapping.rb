# -*- coding: utf-8 -*-

$urlpath_mapping = [
  ['/'                             , "./app/action:TopPage"],
  ['/welcome'                      , "./app/action/welcome:WelcomePage"],
  ['/api', [
    ['/hello'                      , "./app/action/hello:HelloAPI"],
   #['/books'                      , "./app/api/books:BooksAPI"],
   #['/books/{book_id}/comments'   , "./app/api/books:BookCommentsAPI"],
   #['/orders'                     , "./app/api/orders:OrdersAPI"],
  ]],
  ['/admin', [
   #['/books'                      , "./app/admin/books:Admin::BooksPage"],
   #['/orders'                     , "./app/admin/orders:Admi::nOrdersPage"],
  ]],
  ['/static'                       , "./app/action:StaticPage"],
  [''                              , "./app/action:PublicPage"],
]
