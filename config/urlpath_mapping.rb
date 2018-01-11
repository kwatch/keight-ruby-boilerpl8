# -*- coding: utf-8 -*-

$urlpath_mapping = [
  ['/'                             , "./app/action/home:HomePage"],
  ['/welcome'                      , "./app/action/welcome:WelcomePage"],
  ['/api', [
    ['/hello'                      , "./app/api/hello:HelloAPI"],
   #['/books'                      , "./app/api/books:BooksAPI"],
   #['/books/{book_id}/comments'   , "./app/api/books:BookCommentsAPI"],
   #['/orders'                     , "./app/api/orders:OrdersAPI"],
  ]],
  ['/admin', [
   #['/books'                      , "./app/admin/books:Admin::BooksPage"],
   #['/orders'                     , "./app/admin/orders:Admin::OrdersPage"],
  ]],
  ['/static'                       , "./app/action/static:StaticPage"],
  [''                              , "./app/action/public:PublicPage"],
]
