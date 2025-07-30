import type { Product } from '../posDataStruct/posProduct';

export const booksAndMediaProducts: Product[] = [
  {
    ProductId: 1,
    ProductName: 'Novel',
    ProductCode: 'BOOK-001',
    ProductQuantity: 120,
    ProductRate: 14.99,
    ProductImage: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80',
  },
  {
    ProductId: 2,
    ProductName: 'Magazine',
    ProductCode: 'BOOK-002',
    ProductQuantity: 80,
    ProductRate: 5.99,
    ProductImage: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
  },
  {
    ProductId: 3,
    ProductName: 'Audio Book',
    ProductCode: 'BOOK-003',
    ProductQuantity: 60,
    ProductRate: 9.99,
    ProductImage: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=400&q=80',
  },
]; 