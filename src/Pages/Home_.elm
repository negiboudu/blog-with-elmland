module Pages.Home_ exposing (Model, Msg, page)

import Html
import Html.Attributes
import Http
import Json.Decode
import Page exposing (Page)
import View exposing (View)


page : Page Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type Model
    = Failure
    | Loading
    | Success (List ArticleInfo)


type alias ArticleInfo =
    { id : String
    , title : String
    , publishedAt : String
    }


init : ( Model, Cmd Msg )
init =
    ( Loading
    , Http.request
        { method = "GET"
        , headers = [ Http.header "X-MICROCMS-API-KEY" "693bf0dfb658411089e8cc2a27f368394a16" ]
        , url = "https://negiboudu.microcms.io/api/v1/blogs"
        , body = Http.emptyBody
        , expect = Http.expectJson GotArticles decoder
        , timeout = Nothing
        , tracker = Nothing
        }
    )


decoder : Json.Decode.Decoder (List ArticleInfo)
decoder =
    Json.Decode.field "contents" (Json.Decode.list contentsDecoder)


contentsDecoder : Json.Decode.Decoder ArticleInfo
contentsDecoder =
    Json.Decode.map3 ArticleInfo
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "publishedAt" Json.Decode.string)



-- UPDATE


type Msg
    = GotArticles (Result Http.Error (List ArticleInfo))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticles result ->
            case result of
                Ok articleinfolist ->
                    ( Success articleinfolist
                    , Cmd.none
                    )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "ねぎぼうづぶろぐ"
    , body =
        [ Html.h1 [] [ Html.text "ねぎぼうづぶろぐ" ]
        , case model of
            Failure ->
                Html.text "記事の読み込みに失敗しました。もう一度開き直してみてください。"

            Success articleinfolist ->
                let
                    titles articleinfo =
                        Html.li []
                            [ Html.a
                                [ Html.Attributes.href ("/" ++ articleinfo.id) ]
                                [ Html.text (articleinfo.title ++ "\u{3000}" ++ String.left 10 articleinfo.publishedAt) ]
                            ]
                in
                Html.ul []
                    (List.map titles articleinfolist)

            Loading ->
                Html.text "Loading..."
        ]
    }
