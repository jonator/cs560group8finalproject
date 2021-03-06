const generate = require('./generate')

/** Users */

async function insertUser(user) {
  const newUser = {
    userId: generate.id(),
    ...user,
    isAdmin: false,
  }
  db.users.push(newUser)
  const { password, ...safeUser } = newUser // eslint-disable-line
  return safeUser
}

async function getUsers(filter) {
  return filter ? db.users.filter(filter) : [...db.users]
}

async function getUser(userId) {
  const user = (await getUsers(u => u.userId === userId))[0]
  return user
}

async function authenticateUser(auth) {
  const user = (await getUsers(u => u.email === auth.email))[0]
  if (!user) {
    return null
  }
  if (user.password === auth.password) {
    const { password, ...safeUser } = user // eslint-disable-line
    return safeUser
  }
  return undefined
}

/** Cards */

async function insertCard(card) {
  const newCard = {
    cardId: generate.id(),
    ...card,
  }
  db.cards.push(newCard)
  return newCard
}

async function getCards(filter) {
  return filter ? db.cards.filter(filter) : [...db.cards]
}

async function getCard(cardId) {
  return (await getCards(c => c.cardId === cardId))[0]
}

async function updateCard(reqBody) {
  const card = await getCard(parseInt(reqBody.cardId, 10))
  if (!card) {
    return null
  }
  // doing this to make a new copy of the card to avoid subtle bugs
  // that rely on mutation.
  const newCardWithUpdates = Object.assign({}, card, reqBody)
  db.cards[db.cards.indexOf(card)] = newCardWithUpdates
  return newCardWithUpdates
}

async function deleteCard(cardId) {
  const card = await getCard(cardId)
  if (!card) {
    return null
  }
  db.cards = db.cards.filter(c => c.cardId !== cardId)
  return card
}

/** Orders */

const getOrders = async filter => (filter ? db.orders.filter(filter) : [...db.orders])
const getOrder = async orderId => {
  const order = (await getOrders(o => o.orderId === orderId))[0]
  if (!order) {
    return null
  }
  return order
}
const createOrder = async userId => {
  const user = await db.getUser(userId)
  const cartItems = await db.getCartItemsByUser(userId)
  if (!user || !cartItems) {
    return null
  }
  const { password, ...safeUser } = user //eslint-disable-line
  const orderLines = cartItems.map(item => ({ orderLineId: generate.id(), card: item.card, quantity: item.quantity }))
  const order = {
    orderId: generate.id(),
    user: safeUser,
    orderLines,
    orderDate: new Date(Date.now()).toISOString(),
  }
  db.orders.push(order)
  db.cartItems = db.cartItems.filter(cartItem => cartItem.userId !== userId)
  return order
}

const getTotalSales = async () => {
  const total = db.orders.reduce((tot, order) => {
    order.orderLines.forEach(orderLine => {
      const costToAdd = orderLine.card.price * orderLine.quantity
      tot += costToAdd // eslint-disable-line
    })
    return tot
  }, 0)
  if (total) {
    return total
  }
  return undefined
}

const getTotalProfit = async () => {
  const total = 1000
  if (total) {
    return total
  }
  return undefined
}

const getCardsSoldByCategory = async () => {
  const cards = await getCards()
  const ordersByCategory = db.orders.reduce((arr, order) => {
    order.orderLines.forEach(orderLine => {
      const card = cards.filter(c => c.cardId === orderLine.card.cardId)[0]
      if (card) {
        arr.push({ category: card.category, quantity: orderLine.quantity })
      }
    })
    return arr
  }, [])
  const cardsSoldByCategory = ordersByCategory.reduce((arr, cur) => {
    const categoryIndex = arr.findIndex(val => val.category === cur.category)
    if (categoryIndex > -1) {
      arr[categoryIndex].quantity += cur.quantity
      return arr
    }
    arr.push(cur)
    return arr
  }, [])
  return cardsSoldByCategory
}

/** Cart */

const getCartItemsByUser = async userId => {
  const cards = await getCards()
  const cartItems = userId
    ? db.cartItems
      .filter(cartItem => cartItem.userId === userId)
      .map(cartItem => {
        const card = cards.filter(c => c.cardId === cartItem.cardId)[0]
        return { card, quantity: cartItem.quantity }
      })
    : [...db.cartItems]
  if (cartItems.length === 0) {
    return null
  }
  const newCartItems = cartItems.map(function (a) {
    delete a.userId
    return a
  })
  return newCartItems
}

const deleteCartItemsByUser = async userId => {
  const hasAtLeastOne = db.cartItems.some(cartItem => cartItem.userId === userId)
  if (!hasAtLeastOne) {
    return null
  }
  db.cartItems = db.cartItems.filter(cartItem => cartItem.userId !== userId)
  return 'deleted'
}

const insertCartItem = async cartItem => {
  const card = await getCard(cartItem.cardId)
  const user = await getUser(cartItem.userId)
  if (!card || !user) {
    return null
  }
  db.cartItems.push(cartItem)
  return cartItem
}
const updateCartItem = async newInfo => {
  const cartItem = db.cartItems.filter(i => i.userId === newInfo.userId && i.cardId === newInfo.cardId)[0]
  if (!cartItem) {
    return null
  }
  // doing this to make a new copy of the card to avoid subtle bugs
  // that rely on mutation.
  const newCartItemWithUpdates = Object.assign({}, cartItem, newInfo)
  db.cartItems[db.cartItems.indexOf(cartItem)] = newCartItemWithUpdates
  return newCartItemWithUpdates
}

async function deleteCartItem(userId, cardId) {
  const cartItem = db.cartItems.filter(i => i.userId === userId && i.cardId === cardId)[0]
  if (!cartItem) {
    return null
  }
  db.cartItems = db.cartItems.filter(i => !(i.userId === userId && i.cardId === cardId))
  return cartItem
}

const db = {
  users: [],
  cards: [],
  orders: [],
  cartItems: [],

  insertUser,
  getUser,
  getUsers,
  authenticateUser,

  insertCard,
  getCard,
  getCards,
  updateCard,
  deleteCard,

  getOrders,
  getOrder,
  getTotalSales,
  getTotalProfit,
  getCardsSoldByCategory,
  createOrder,

  getCartItemsByUser,
  deleteCartItemsByUser,
  insertCartItem,
  updateCartItem,
  deleteCartItem,
}

module.exports = db
