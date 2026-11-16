import { MasterKey } from '../../core/services/admin';
import { IconName } from '../../shared/icon';

/** Config for the simple master tables, shared by the routes and the sidebar. */
export interface MasterConfig {
  key: MasterKey;
  title: string;
  singular: string;
  placeholder: string;
  icon: IconName;
  hasHex?: boolean;
}

export const MASTER_CONFIGS: MasterConfig[] = [
  { key: 'age-groups', title: 'Age groups', singular: 'age group', placeholder: 'e.g. 3-5 Years', icon: 'smile' },
  { key: 'genders', title: 'Genders', singular: 'gender', placeholder: 'e.g. Boys', icon: 'user' },
  { key: 'materials', title: 'Materials', singular: 'material', placeholder: 'e.g. Plastic', icon: 'layers' },
  { key: 'colors', title: 'Colors', singular: 'color', placeholder: 'e.g. Red', icon: 'droplet', hasHex: true },
];
