// fe/pages/api/renderPage.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { renderToString } from 'react-dom/server';
import Page from '../../src/app/page';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    const html = renderToString(`<div>dsds<div/>`);
    res.status(200).send(html);
  } catch (error) {
    console.error('Error rendering page:', error);
    res.status(500).send('Internal Server Error');
  }
}
