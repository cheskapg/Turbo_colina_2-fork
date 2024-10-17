// fe/pages/api/renderPage.js

import { NextApiRequest, NextApiResponse } from 'next';
import { renderToString } from 'react-dom/server';
import Page from '../../src/app/page';
export default async function handler(req, res) {
  try {
    const html = renderToString(Page());
    res.status(200).send(html);
  } catch (error) {
    console.error('Error rendering page:', error);
    res.status(500).send('Internal Server Error');
  }
}
