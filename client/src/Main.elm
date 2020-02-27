module Main exposing (main)

import Browser
import Element exposing (Element, column, el, padding, row)
import Element.Font as Font
import Flip exposing (flip)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, float, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import LineChart
import LineChart.Area as LCArea
import LineChart.Axis as LCAxis
import LineChart.Axis.Intersection as LCIntersection
import LineChart.Axis.Line as LCAxisLine
import LineChart.Axis.Range as LCAxisRange
import LineChart.Axis.Tick as LCAxisTick
import LineChart.Axis.Ticks as LCAxisTicks
import LineChart.Axis.Title as LCAxisTitle
import LineChart.Colors as LCColors
import LineChart.Container as LCContainer
import LineChart.Coordinate as LCCoordinate
import LineChart.Dots as LCDots
import LineChart.Events as LCEvents
import LineChart.Grid as LCGrid
import LineChart.Interpolation as LCInterpolation
import LineChart.Junk as LCJunk
import LineChart.Legends as LCLegends
import LineChart.Line as LCLine
import Time
import Time.Format as TimeFormat


apiUrlPrefix : String
apiUrlPrefix =
    "http://localhost:4567"


type alias Model =
    { sites : List Site
    , status : Status
    , activeSite : Maybe Site
    , hoveredSiteCheck : Maybe SiteCheck
    }


setSites : List Site -> Model -> Model
setSites newSites model =
    { model | sites = newSites }


setStatus : Status -> Model -> Model
setStatus newStatus model =
    { model | status = newStatus }


setActiveSite : Site -> Model -> Model
setActiveSite newActiveSite model =
    { model | activeSite = Just newActiveSite }


asActiveSiteIn : Model -> Site -> Model
asActiveSiteIn =
    flip setActiveSite


setHoveredSiteCheck : Maybe SiteCheck -> Model -> Model
setHoveredSiteCheck newHoveredSiteCheck model =
    { model | hoveredSiteCheck = newHoveredSiteCheck }


type alias Site =
    { id : String
    , url : String
    , email : String
    , status : String
    , duration : Int
    , checks : List SiteCheck
    }


setSiteChecks : List SiteCheck -> Site -> Site
setSiteChecks newSiteChecks site =
    { site | checks = newSiteChecks }


type alias SiteCheck =
    { id : Int
    , response : Int
    , responseTime : Float
    , siteId : String
    , url : String
    , createdAt : Time.Posix
    }


type Msg
    = FetchSites
    | SitesFetched (Result Http.Error (List Site))
    | FetchSite Site
    | SiteChecksFetched (Result Http.Error (List SiteCheck))
    | ShowSiteDetails Site
    | HoverSiteCheck (Maybe SiteCheck)
    | Noop


type Status
    = NotLoaded
    | Loading
    | Loaded
    | Errored String


view : Model -> Html Msg
view model =
    Element.layout [ padding 20, Font.size 14 ]
        (column
            []
            [ Element.html
                (button [ onClick FetchSites ]
                    [ text "Fetch Sites List" ]
                )
            , Element.html (viewSitesList model)
            , Element.html (hr [] [])
            , Element.html (viewSiteDetails model)
            ]
        )


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


viewSiteDetails : Model -> Html Msg
viewSiteDetails model =
    case model.activeSite of
        Just site ->
            div [ class "site-details" ]
                [ h2 [] [ text (site.url ++ " - " ++ site.status) ]
                , viewSiteChecksChart model
                ]

        Nothing ->
            div [ class "site-details empty" ] []


viewSiteChecksChart : Model -> Html Msg
viewSiteChecksChart model =
    case model.activeSite of
        Just site ->
            LineChart.viewCustom (chartConfig model) [ LineChart.line LCColors.blue LCDots.circle "" site.checks ]

        Nothing ->
            div [ class "site-shart empty" ] []


chartConfig : Model -> LineChart.Config SiteCheck Msg
chartConfig model =
    { y = LCAxis.full 450 "Response Time in ms" .responseTime
    , x = LCAxis.time Time.utc 1270 "Time" (toFloat << Time.posixToMillis << .createdAt)
    , container = LCContainer.default "uptime"
    , interpolation = LCInterpolation.monotone
    , intersection = LCIntersection.default
    , legends = LCLegends.none
    , events = LCEvents.hoverOne HoverSiteCheck
    , junk = viewSiteCheckJunk model
    , grid = LCGrid.lines 0.3 LCColors.gray
    , area = LCArea.normal 1.0
    , line = LCLine.default
    , dots = LCDots.custom (LCDots.empty 5 1)
    }


viewSiteCheckJunk : Model -> LCJunk.Config SiteCheck msg
viewSiteCheckJunk model =
    case model.hoveredSiteCheck of
        Nothing ->
            LCJunk.default

        Just _ ->
            LCJunk.hoverOne model.hoveredSiteCheck
                [ ( "Timestamp", formattedJunkTimestamp << .createdAt )
                , ( "Response Time in ms", String.fromFloat << .responseTime )
                , ( "Status Code", String.fromInt << .response )
                ]


formattedJunkTimestamp : Time.Posix -> String
formattedJunkTimestamp timestamp =
    timestamp
        |> Time.posixToMillis
        |> TimeFormat.format Time.utc "Weekday, Month Day, Year padHour:padMinute"


customAxis : LCAxis.Config SiteCheck msg
customAxis =
    LCAxis.custom
        { title = LCAxisTitle.default "Time"
        , variable = Just << (toFloat << Time.posixToMillis << .createdAt)
        , pixels = 1270
        , range = LCAxisRange.padded 20 20
        , axisLine = LCAxisLine.rangeFrame LCColors.gray
        , ticks = LCAxisTicks.timeCustom Time.utc 8 customTimeTick
        }


customTimeTick : LCAxisTick.Time -> LCAxisTick.Config msg
customTimeTick timestamp =
    let
        formattedTime =
            TimeFormat.format Time.utc "padHour:padMinute:padSecond" (Time.posixToMillis timestamp.timestamp)

        label =
            LCJunk.label LCColors.black formattedTime
    in
    LCAxisTick.custom
        { position = toFloat <| Time.posixToMillis timestamp.timestamp
        , color = LCColors.gray
        , width = 1
        , length = 7
        , grid = True
        , direction = LCAxisTick.negative
        , label = Just label
        }


timestampDecoder : Decoder Time.Posix
timestampDecoder =
    -- The API gives a timestamp in seconds, not milliseconds
    Json.Decode.map (\ts -> Time.millisToPosix (ts * 1000)) int


siteCheckDecoder : Decoder SiteCheck
siteCheckDecoder =
    succeed SiteCheck
        |> required "id" int
        |> required "response" int
        |> required "responseTime" float
        |> required "siteId" string
        |> required "url" string
        |> required "createdAt" timestampDecoder


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
            ( setStatus Loaded model, fetchSitesCmd )

        SitesFetched result ->
            case result of
                Ok sites ->
                    ( model
                        |> setSites sites
                        |> setStatus Loaded
                    , Cmd.none
                    )

                Err httpError ->
                    case httpError of
                        Http.BadStatus status ->
                            ( setStatus (Errored "Bad Status Code returned ") model, Cmd.none )

                        Http.NetworkError ->
                            ( setStatus (Errored "Network Error") model, Cmd.none )

                        Http.Timeout ->
                            ( setStatus (Errored "Timeout") model, Cmd.none )

                        Http.BadUrl badUrl ->
                            ( setStatus (Errored ("Bad Url: " ++ badUrl)) model, Cmd.none )

                        Http.BadBody body ->
                            ( setStatus (Errored ("Bad Body: " ++ body)) model, Cmd.none )

        ShowSiteDetails site ->
            ( setActiveSite site model, fetchSiteChecksCmd site )

        SiteChecksFetched result ->
            case result of
                Ok siteChecks ->
                    case model.activeSite of
                        Just activeSite ->
                            ( activeSite
                                |> setSiteChecks siteChecks
                                |> asActiveSiteIn model
                            , Cmd.none
                            )

                        Nothing ->
                            ( model, Cmd.none )

                Err httpError ->
                    ( setStatus (Errored "Failed to load site checks...") model, Cmd.none )

        HoverSiteCheck coordinatePoint ->
            ( setHoveredSiteCheck coordinatePoint model, Cmd.none )

        _ ->
            ( model, Cmd.none )


initialModel : Model
initialModel =
    { sites = [], status = NotLoaded, activeSite = Nothing, hoveredSiteCheck = Nothing }


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
