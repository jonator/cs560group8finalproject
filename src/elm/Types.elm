module Types exposing (Card, CartItem, Model, Msg(..), Page(..), User)

import Dict exposing (Dict)


type alias Model =
    { user : Maybe User
    , page : Page
    }


type alias User =
    { userId : Int
    , firstName : String
    , lastName : String
    , cart : Dict CardId (CartItem Card)
    }


type Page
    = Loading
    | SignIn
    | Homepage (List Card)
    | CardView Card
    | CartView
    | AdminPage TotalSales OrderCount (List Order) TotalProfit


type alias Card =
    { cardId : Int
    , title : String
    , imageUrl : String
    , cost : Int
    , category : String
    }


type alias CartItem a =
    { quantity : Int
    , item : a
    }


type alias TotalSales =
    Int


type alias OrderCount =
    Int


type alias TotalProfit =
    Int


type alias Email =
    String


type alias FirstName =
    String


type alias LastName =
    String


type alias Password =
    String


type alias CardId =
    Int


type alias Order =
    { orderId : Int
    , user : User
    , orderLines : List OrderLine
    , orderDate : String -- temp
    }


type alias OrderLine =
    { orderLineId : Int
    , card : Card
    , quantity : Int
    }


type Msg
    = HandleCards (Result String (List Card))
    | ClickCard Card
    | ClickTitleText
    | ClickSignIn
    | Authenticate Email Password
    | Register FirstName LastName Email Password
    | ClickAddToCart Card
