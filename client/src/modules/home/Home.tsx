import * as react from "react";
import { NextPage } from "next";
import { getAllSites } from "../../pages/api/sites"
import { Site } from "@components/types/Site"
import Link from "next/link"

interface Props {
    data: [Site]
}

export const Home: NextPage<Props> = (Props) => {
    console.log("Data in Home render: ", Props)
    return (
        <div>
            <h1>Welcome to a Dogfood version of THE Situation Room!</h1>
            <h2>Current Sites:</h2>
            {
                Props.data.map((site: Site) => (
                    <Link href="/">
                        <p>id: {site.id} - name: {site.name} - endpoint: {site.endpoint}</p>
                    </Link>
                ))
            }
        </div>
    )
}

export async function getServerSideProps() {
    // return await getAllSites().then((sites: [Site]) => {
    //     console.log(sites)
    //     return { props: { sites } }
    // }
    const data = await getAllSites()
    console.log ("Data from ServerSideProps: ", data)
    return { data }
}