import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Setting } from './entities/setting.entity';

@Injectable()
export class SettingsService {
  constructor(
    @InjectRepository(Setting)
    private readonly settingRepository: Repository<Setting>,
  ) {}

  async findByKey(key: string): Promise<any> {
    const setting = await this.settingRepository.findOne({ where: { key } });
    return setting ? setting.value : null;
  }

  async updateByKey(key: string, value: any): Promise<any> {
    let setting = await this.settingRepository.findOne({ where: { key } });
    
    if (setting) {
      setting.value = value;
      return await this.settingRepository.save(setting);
    } else {
      setting = this.settingRepository.create({ key, value });
      return await this.settingRepository.save(setting);
    }
  }

  async getAll(): Promise<any> {
    const settings = await this.settingRepository.find();
    const result: any = {};
    settings.forEach(s => {
      result[s.key] = s.value;
    });
    return result;
  }
}
