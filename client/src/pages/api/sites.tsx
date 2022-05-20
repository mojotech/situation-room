import Link from "next/link";
import { Site } from "@components/types/Site";

export async function getAllSites() {
    return sendRequest('/sites').then((res: [Site]) => {
        return res
    })
}

export async function getSiteById(id: string) {
    return sendRequest(`/sites/${id}`).then((res: [Site]) => {
        return res
    })
}

async function sendRequest(route: string) {
    const res = await fetch(`http://localhost:4001/${route}`)
    const data: [Site] = await res.json()
    console.log(data)
    return data
}

