module.exports = {
  root: true,
  parserOptions: {
    ecmaVersion: 6,
    sourceType: 'module'
  },
  env: {
    browser: true,
    es6: true
  },
  extends: 'eslint:recommended',
  rules: {
    'no-bitwise': 'error',
    'curly': 'error',
    'guard-for-in': 'error',
    'eqeqeq': 'error',
    'no-use-before-define': 'error',
    'no-caller': 'error',
    'no-irregular-whitespace': 'error'
  }
}