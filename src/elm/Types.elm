module Types
    exposing
        ( AuthMsg(..)
        , Card
        , Quantity
        , CardId
        , CardsSoldByCategory
        , CartItem
        , Collapsible
        , CreateCardModel
        , Model
        , Msg(..)
        , Order
        , OrderCount
        , OrderLine
        , Page(..)
        , TotalProfit
        , TotalSales
        , User
        )

import Dict exposing (Dict)
import SignIn


type alias Model =
    { user : Maybe User
    , page : Page
    }


type alias User =
    { userId : Int
    , firstName : String
    , lastName : String
    , email : String
    , isAdmin : Bool
    , cart : Dict CardId (CartItem Card)
    }


type alias CardsSoldByCategory =
    { category : String
    , quantity : Int
    }


type Page
    = Loading
    | SignIn SignIn.Model
    | Homepage (List Card) CreateCardModel
    | CardView Card Quantity
    | CartView
    | AdminPage TotalSales OrderCount (List (Collapsible Order)) TotalProfit (List CardsSoldByCategory)
    | DeleteCardView CardId


type alias Card =
    { cardId : Int
    , title : String
    , imageUrl : String
    , price : Int
    , costToProduce : Int
    , category : String
    }


type alias CreateCardModel =
    { title : String
    , price : String
    , costToProduce : String
    , category : String
    , imgUrl : String
    }


type alias CartItem a =
    { item : a
    , quantity : Int
    }


type alias TotalSales =
    Int


type alias OrderCount =
    Int


type alias TotalProfit =
    Int


type alias CardId =
    Int


type alias Quantity =
    Int


type alias Collapsible a =
    { item : a
    , collapsed : Bool
    }


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
    | HandleRegisterUser (Result String User)
    | HandleAuthenticateUser (Result String User)
    | SignInMsgs SignIn.SignInMsg
    | ClickCard Card
    | ClickBackToCards
    | ClickTitleText
    | ClickSignIn
    | AuthenticatedMsgs AuthMsg



--Event that requires user to be authenticated


type AuthMsg
    = HandleUpdateCartItem (Result String String)
    | HandleGetUserCart (Result String (List (CartItem Card)))
    | HandleCreateCard (Result String String)
    | HandleUpdateCard (Result String String)
    | HandleDeleteCard (Result String String)
    | HandleDeleteCartItem (Result String String)
    | HandleCreateCartItem (Result String String)
    | HandleGetAllOrders (Result String (List Order))
    | HandleGetTotalSales (Result String Int)
    | HandleGetTotalProfit (Result String Int)
    | HandleGetCardsSoldByCategory (Result String (List CardsSoldByCategory))
    | HandleCreateOrder (Result String String)
    | ClickAddToCart
    | ClickCart
    | ClickSignOut
    | ClickChangeCardViewCardQuantity String
    | CartCardQuantityChange CardId String
    | ClickMyStore
    | ClickCreateCard
    | ClickDeleteCartItem (CartItem Card)
    | TypeEditCardTitle Card String
    | TypeEditCardPrice Card String
    | TypeEditCardCategory Card String
    | TypeEditCardImgUrl Card String
    | TypeEditNewCardTitle String
    | TypeEditNewCardPrice String
    | TypeEditNewCardCostToProduce String
    | TypeEditNewCardCategory String
    | TypeEditNewCardImgUrl String
    | ClickUpdateCard Card
    | ClickDeleteCard Card
    | ClickToggleOrderCollapsed Order
    | ClickPurchaseCart
