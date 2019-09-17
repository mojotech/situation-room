module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)


apiUrlPrefix : String
apiUrlPrefix =
    "http://localhost:8888"


type alias Model =
    { sites : List Site
    , status : Status
    }


type alias Site =
    { id : String
    , url : String
    , email : String
    , status : String
    , duration : Int
    }


type Msg
    = FetchSites
    | SitesFetched (Result Http.Error (List Site))
    | FetchSite Site
    | Noop


type Status
    = NotLoaded
    | Loading
    | Loaded
    | Errored String


view : Model -> Html Msg
view model =
    div []
        [ div [ class "controls" ]
            [ button [ onClick FetchSites ]
                [ text "Fetch Sites List" ]
            ]
        , div [ class "content" ]
            [ viewSitesList model ]
        ]


viewSitesList : Model -> Html Msg
viewSitesList model =
    section [ class "sites-list" ]
        (case model.status of
            NotLoaded ->
                [ text "Please fetch sites list..." ]

            Loaded ->
                [ h2 [] [ text "Monitored Sites" ]
                , div [] (List.map viewSiteCard model.sites)
                ]

            Loading ->
                [ text "...Fetching Sites.  Please Wait..." ]

            Errored errMessage ->
                [ text ("Error: " ++ errMessage) ]
        )


viewSiteCard : Site -> Html Msg
viewSiteCard site =
    div [ class "site-card" ]
        [ text site.url ]


siteDecoder : Decoder Site
siteDecoder =
    succeed Site
        |> required "id" string
        |> required "url" string
        |> required "email" string
        |> optional "status" string ""
        |> required "duration" int


fetchSitesCmd : Cmd Msg
fetchSitesCmd =
    Http.get
        { url = apiUrlPrefix ++ "/sites"
        , expect = Http.expectJson SitesFetched (list siteDecoder)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchSites ->
            ( { model | status = Loading }, fetchSitesCmd )

        SitesFetched result ->
            case result of
                Ok sites ->
                    ( { model | sites = sites, status = Loaded }, Cmd.none )

                Err httpError ->
                    case httpError of
                        Http.BadStatus status ->
                            ( { model | status = Errored "Bad Status Code returned " }, Cmd.none )

                        Http.NetworkError ->
                            ( { model | status = Errored "Network Error" }, Cmd.none )

                        Http.Timeout ->
                            ( { model | status = Errored "Timeout" }, Cmd.none )

                        Http.BadUrl badUrl ->
                            ( { model | status = Errored ("Bad Url: " ++ badUrl) }, Cmd.none )

                        Http.BadBody body ->
                            ( { model | status = Errored ("Bad Body: " ++ body) }, Cmd.none )

        -- _ ->
        --     ( { model | status = Errored "Server error!" }, Cmd.none )
        _ ->
            ( model, Cmd.none )


initialModel : Model
initialModel =
    { sites = [], status = NotLoaded }


initialCmd : Cmd Msg
initialCmd =
    Cmd.none


main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( initialModel, initialCmd )
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }
