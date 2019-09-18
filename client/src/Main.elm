module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, float, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import LineChart


apiUrlPrefix : String
apiUrlPrefix =
    "http://localhost:4567"


type alias Model =
    { sites : List Site
    , status : Status
    , activeSite : Maybe Site
    }


type alias Site =
    { id : String
    , url : String
    , email : String
    , status : String
    , duration : Int
    , checks : List SiteCheck
    }


type alias SiteCheck =
    { id : Int
    , response : Float
    , responseTime : Int
    , siteId : String
    , url : String
    , createdAt : Int
    }


type Msg
    = FetchSites
    | SitesFetched (Result Http.Error (List Site))
    | FetchSite Site
    | SiteChecksFetched (Result Http.Error (List SiteCheck))
    | ShowSiteDetails Site
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
            [ viewSitesList model
            , hr [] []
            , viewSiteDetails model.activeSite
            ]
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
    div [ class "site-card", onClick (ShowSiteDetails site) ]
        [ text site.url ]


viewSiteDetails : Maybe Site -> Html Msg
viewSiteDetails maybeSite =
    case maybeSite of
        Just site ->
            div [ class "site-details" ]
                [ h2 [] [ text site.url ]
                , LineChart.view1 (\c -> toFloat c.createdAt) (\c -> toFloat c.responseTime) site.checks
                , table []
                    [ thead []
                        [ tr []
                            [ th [] [ text "Tested" ]
                            , th [] [ text "Code" ]
                            , th [] [ text "Response Time" ]
                            ]
                        ]
                    , tbody [] (List.map siteCheckTableRow site.checks)
                    ]
                ]

        Nothing ->
            div [ class "site-details empty" ] []


siteCheckTableRow : SiteCheck -> Html Msg
siteCheckTableRow siteCheck =
    tr []
        [ td [] [ text (String.fromInt siteCheck.createdAt) ]
        , td [] [ text (String.fromFloat siteCheck.response) ]
        , td [] [ text (String.fromInt siteCheck.responseTime) ]
        ]


siteCheckDecoder : Decoder SiteCheck
siteCheckDecoder =
    succeed SiteCheck
        |> required "id" int
        |> required "response" float
        |> required "responseTime" int
        |> required "siteId" string
        |> required "url" string
        |> required "createdAt" int


siteDecoder : Decoder Site
siteDecoder =
    succeed Site
        |> required "id" string
        |> required "url" string
        |> required "email" string
        |> optional "status" string ""
        |> required "duration" int
        |> hardcoded []


fetchSiteChecksCmd : Site -> Cmd Msg
fetchSiteChecksCmd site =
    Http.get
        { url = apiUrlPrefix ++ "/sites/" ++ site.id ++ "/checks"
        , expect = Http.expectJson SiteChecksFetched (list siteCheckDecoder)
        }


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

        ShowSiteDetails site ->
            ( { model | activeSite = Just site }, fetchSiteChecksCmd site )

        SiteChecksFetched result ->
            case result of
                Ok siteChecks ->
                    case model.activeSite of
                        Just activeSite ->
                            let
                                updatedSite =
                                    { activeSite | checks = siteChecks }
                            in
                            ( { model | activeSite = Just updatedSite }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Err httpError ->
                    ( { model | status = Errored "Failed to load site checks..." }, Cmd.none )

        _ ->
            ( model, Cmd.none )


initialModel : Model
initialModel =
    { sites = [], status = NotLoaded, activeSite = Nothing }


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
