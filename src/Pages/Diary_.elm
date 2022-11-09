module Pages.Diary_ exposing (Model, Msg, page)

import Html
import Html.Attributes
import Http
import Json.Decode
import Markdown
import Page exposing (Page)
import View exposing (View)


page : { diary : String } -> Page Model Msg
page params =
    Page.element
        { init = init params
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type Model
    = Failure
    | Loading
    | Success Diary


type alias Diary =
    { id : String
    , title : String
    , content : String
    , publishedAt : String
    }


init : { diary : String } -> ( Model, Cmd Msg )
init params =
    ( Loading
    , Http.request
        { method = "GET"
        , headers = [ Http.header "X-MICROCMS-API-KEY" "693bf0dfb658411089e8cc2a27f368394a16" ]
        , url = "https://negiboudu.microcms.io/api/v1/blogs/" ++ params.diary
        , body = Http.emptyBody
        , expect = Http.expectJson GotDiary decoder
        , timeout = Nothing
        , tracker = Nothing
        }
    )


decoder : Json.Decode.Decoder Diary
decoder =
    Json.Decode.map4 Diary
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "content" Json.Decode.string)
        (Json.Decode.field "publishedAt" Json.Decode.string)



-- UPDATE


type Msg
    = GotDiary (Result Http.Error Diary)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotDiary result ->
            case result of
                Ok diary ->
                    ( Success diary
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
        [ case model of
            Failure ->
                Html.text "記事の読み込みに失敗しました。もう一度開き直してみてください。"

            Success diary ->
                Html.div []
                    [ Html.h1 [] [ Html.text diary.title ]
                    , Html.p [] [ Html.text (String.left 10 diary.publishedAt) ]
                    , Markdown.toHtmlWith
                        { githubFlavored = Nothing
                        , defaultHighlighting = Nothing
                        , sanitize = False
                        , smartypants = False
                        }
                        []
                        diary.content
                    ]

            Loading ->
                Html.text "Loading..."
        , Html.br [] []
        , Html.a [ Html.Attributes.href "/" ] [ Html.text "記事一覧に戻る" ]
        ]
    }
