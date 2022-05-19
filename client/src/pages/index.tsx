import type { NextPage } from 'next'
import Head from 'next/head'
import { Home } from "@modules/home"
import { Footer } from "@components/Footer" 

const IndexPage: NextPage = () => {
  return (
    <div>
      <Head>
        <title>Situation Room</title>
        <meta name="description" content="By Mojotech" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Home />
      <Footer />
    
    </div>
  )
}

export default IndexPage;
