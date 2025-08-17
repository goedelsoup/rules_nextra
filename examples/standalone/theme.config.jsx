export default {
  logo: <span>My Documentation</span>,
  project: {
    link: 'https://github.com/your-org/your-repo',
  },
  docsRepositoryBase: 'https://github.com/your-org/your-repo/tree/main',
  footer: {
    text: 'MIT 2024 © Your Organization.',
  },
  useNextSeoProps() {
    return {
      titleTemplate: '%s – My Documentation'
    }
  },
  head: (
    <>
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <meta property="og:title" content="My Documentation" />
      <meta property="og:description" content="Documentation built with Nextra and Bazel" />
    </>
  ),
}
