module View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes as Attrs
import Html.Events exposing (..)
import Types exposing (..)
import SignIn


view : Model -> Html Msg
view model =
    div [ Attrs.class "main" ] <|
        content model


content : Model -> List (Html Msg)
content model =
    let
        head =
            header model

        content =
            case model.user of
                Just user ->
                    case model.page of
                        CartView ->
                            cart <| List.map Tuple.second <| Dict.toList user.cart

                        Homepage cardList ->
                            homepage user.isAdmin cardList

                        CardView c ->
                            cardView c

                        AdminPage totalSales orderCount orderList totalProfit ->
                            adminPage totalSales orderCount orderList totalProfit

                        Loading ->
                            loading

                        _ ->
                            div [] [ text "Other authed page!" ]

                Nothing ->
                    case model.page of
                        Homepage cardList ->
                            homepage False cardList

                        CardView c ->
                            cardView c

                        SignIn signInModel ->
                            SignIn.view signInModel SignInMsgs

                        Loading ->
                            loading

                        _ ->
                            div [] [ text "Must be authenticated to view this page!" ]
    in
        [ head
        , div [ Attrs.class "content" ] [ content ]
        ]


header : Model -> Html Msg
header model =
    let
        userControls =
            case model.user of
                Just user ->
                    let
                        cartCount =
                            user.cart
                                |> Dict.toList
                                |> List.length
                                |> toString

                        adminButton =
                            if user.isAdmin then
                                [ div
                                    [ Attrs.class "mystore button"
                                    , onClick <| AuthenticatedMsgs <| ClickMyStore
                                    ]
                                    [ text "MyStore" ]
                                ]
                            else
                                []

                        cartButton =
                            if user.isAdmin then
                                div [] []
                            else
                                div
                                    [ Attrs.class "cart button"
                                    , onClick <| AuthenticatedMsgs <| ClickCart
                                    ]
                                    [ text ("Cart [" ++ cartCount ++ "]") ]
                    in
                        ([ div [ Attrs.class "user-email" ]
                            [ text user.email ]
                         , cartButton
                         , div
                            [ Attrs.class "sign-out button"
                            , onClick <| AuthenticatedMsgs <| ClickSignOut
                            ]
                            [ text "Sign out" ]
                         ]
                            ++ adminButton
                        )

                Nothing ->
                    [ div [ Attrs.class "sign-in button", onClick ClickSignIn ]
                        [ text "Sign in" ]
                    ]
    in
        div [ Attrs.class "header" ]
            ([ div [ Attrs.class "title-text", onClick ClickTitleText ]
                [ text "Cheeky Beak Card Company" ]
             ]
                ++ userControls
            )


homepage : Bool -> List Card -> Html Msg
homepage isAdmin cardList =
    div [ Attrs.class "cards" ] <|
        List.map (card isAdmin) cardList


cardView : Card -> Html Msg
cardView c =
    div [ Attrs.class "card-view" ]
        [ card False c
        , div [ Attrs.class "actions" ]
            [ div
                [ Attrs.class "back-to-cards button"
                , onClick ClickBackToCards
                ]
                [ text "<- Back to all cards" ]
            , addToCartBtn <| AuthenticatedMsgs <| ClickAddToCart c
            ]
        ]


loading : Html Msg
loading =
    div [ Attrs.class "loading" ]
        [ text "Loading!" ]


card : Bool -> Card -> Html Msg
card isAdmin c =
    if isAdmin then
        div [ Attrs.class "card" ]
            [ div [ Attrs.class "info" ]
                [ div [ Attrs.class "id" ]
                    [ text <| toString c.cardId ]
                , input
                    [ Attrs.class "title input"
                    , Attrs.placeholder c.title
                    , onInput <| AuthenticatedMsgs << TypeEditCardTitle c
                    ]
                    []
                , input
                    [ Attrs.class "price input"
                    , Attrs.placeholder <| String.append "$" <| toString c.price
                    , onInput <| AuthenticatedMsgs << TypeEditCardPrice c
                    ]
                    []
                , input
                    [ Attrs.class "category input"
                    , Attrs.placeholder c.category
                    , onInput <| AuthenticatedMsgs << TypeEditCardCategory c
                    ]
                    []
                , input
                    [ Attrs.class "image-input"
                    , Attrs.placeholder c.imageUrl
                    , onInput <| AuthenticatedMsgs << TypeEditCardImgUrl c
                    ]
                    []
                ]
            , div [ Attrs.class "image" ]
                [ img [ Attrs.src c.imageUrl ] [] ]
            , div [ Attrs.class "update-card button", onClick <| AuthenticatedMsgs <| ClickUpdateCard c ]
                [ text "Update" ]
            , div [ Attrs.class "delete-card button", onClick <| AuthenticatedMsgs <| ClickDeleteCard c ]
                [ text "Delete" ]
            ]
    else
        div [ Attrs.class "card", onClick <| ClickCard c ]
            [ div [ Attrs.class "info" ]
                [ div [ Attrs.class "id" ]
                    [ text <| toString c.cardId ]
                , div [ Attrs.class "title" ]
                    [ text c.title ]
                , div [ Attrs.class "price" ]
                    [ text <| String.append "$" <| toString c.price ]
                , div [ Attrs.class "category" ]
                    [ text c.category ]
                ]
            , div [ Attrs.class "image" ]
                [ img [ Attrs.src c.imageUrl ] [] ]
            ]


addToCartBtn : msg -> Html msg
addToCartBtn m =
    div
        [ Attrs.class "add-to-cart-btn button"
        , onClick m
        ]
        [ text "Add to cart" ]


cart : List (CartItem Card) -> Html Msg
cart cardList =
    div [ Attrs.class "cart" ] <|
        List.map
            cartItem
            cardList


cartItem : CartItem Card -> Html Msg
cartItem cartCard =
    div [ Attrs.class "cart-card card" ]
        [ div [ Attrs.class "info" ]
            [ div [ Attrs.class "id" ]
                [ text <| toString cartCard.item.cardId ]
            , div [ Attrs.class "title" ]
                [ text cartCard.item.title ]
            , div [ Attrs.class "price" ]
                [ text <| String.append "$" <| toString cartCard.item.price ]
            , div [ Attrs.class "category" ]
                [ text cartCard.item.category ]
            , cartItemQuantity cartCard.item.cardId cartCard.quantity
            , div
                [ Attrs.class "delete-cart-item button"
                , onClick <| AuthenticatedMsgs <| ClickDeleteCartItem cartCard
                ]
                [ text "Delete from cart" ]
            ]
        , div [ Attrs.class "image" ]
            [ img [ Attrs.src cartCard.item.imageUrl ]
                []
            ]
        ]


cartItemQuantity : CardId -> Int -> Html Msg
cartItemQuantity cardId quantity =
    div [ Attrs.class "quantity" ]
        [ input
            [ Attrs.type_ "number"
            , Attrs.value <| toString quantity
            , onInput <| AuthenticatedMsgs << CartCardQuantityChange cardId
            ]
            []
        ]


adminPage : TotalSales -> OrderCount -> List Types.Order -> TotalProfit -> Html Msg
adminPage totalSales orderCount orderList totalProfit =
    div [ Attrs.class "admin" ]
        [ text "Administrator"
        , div [ Attrs.class "order-list" ]
            ([ text "Order(s):" ] ++ List.map order orderList)
        , div [ Attrs.class "total-sales" ]
            [ text <| (++) "Total Sales: $" <| toString totalSales ]
        , div [ Attrs.class "total-profit" ]
            [ text <| (++) "Total Profit: $" <| toString totalProfit ]
        , div [ Attrs.class "order-count" ]
            [ text <| (++) "Order Count: " <| toString orderCount ]
        ]


order : Types.Order -> Html Msg
order o =
    div [ Attrs.class "order" ]
        ([ text <| (++) "Order ID: " <| toString o.orderId
         , orderUser o.user
         ]
            ++ List.map orderLine o.orderLines
        )


orderUser : User -> Html msg
orderUser user =
    div [ Attrs.class "order-user" ]
        [ text "User:"
        , div [ Attrs.class "user-id" ]
            [ text <| (++) "ID: " <| toString user.userId ]
        , div [ Attrs.class "first-name" ]
            [ text <| (++) "First Name: " user.firstName ]
        , div [ Attrs.class "last-name" ]
            [ text <| (++) "Last Name: " user.lastName ]
        ]


orderLine : OrderLine -> Html Msg
orderLine oLine =
    div [ Attrs.class "order-line" ]
        [ div [ Attrs.class "id" ]
            [ text <| (++) "Order line id: " <| toString oLine.orderLineId ]
        , orderLineCard oLine.card
        , div [ Attrs.class "quantity" ]
            [ text <| (++) "Quantity: " <| toString oLine.quantity ]
        ]


orderLineCard : Card -> Html msg
orderLineCard card =
    div [ Attrs.class "card" ]
        [ div [ Attrs.class "info" ]
            [ div [ Attrs.class "card-id" ]
                [ text <| (++) "Card Id: " <| toString card.cardId ]
            , div [ Attrs.class "title" ]
                [ text <| (++) "Title: " card.title ]
            , div [ Attrs.class "price" ]
                [ text <| (++) "Price: $" <| toString card.price ]
            , div [ Attrs.class "category" ]
                [ text <| (++) "Category: " card.category ]
            ]
        , div [ Attrs.class "image" ]
            [ img
                [ Attrs.src <| reduceImageSize card.imageUrl
                ]
                []
            ]
        ]


reduceImageSize : String -> String
reduceImageSize link =
    if String.contains "_" link && String.contains ".jpg" link then
        let
            replace from to str =
                String.split from str
                    |> String.join to
        in
            replace "400" "200" link
    else
        link
