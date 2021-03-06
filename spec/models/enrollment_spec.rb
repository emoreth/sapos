# Copyright (c) 2013 Universidade Federal Fluminense (UFF).
# This file is part of SAPOS. Please, consult the license terms in the LICENSE file.

require "spec_helper"

describe Enrollment do
  let(:enrollment) { Enrollment.new }
  subject { enrollment }
  describe "Validations" do
    describe "student" do
      context "should be valid when" do
        it "student is not null" do
          enrollment.student = Student.new
          enrollment.should have(0).errors_on :student
        end
      end
      context "should have error blank when" do
        it "student is null" do
          enrollment.student = nil
          enrollment.should have_error(:blank).on :student
        end
      end
    end
    describe "enrollment_status" do
      context "should be valid when" do
        it "enrollment_status is not null" do
          enrollment.enrollment_status = EnrollmentStatus.new
          enrollment.should have(0).errors_on :enrollment_status
        end
      end
      context "should have error blank when" do
        it "enrollment_status is null" do
          enrollment.enrollment_status = nil
          enrollment.should have_error(:blank).on :enrollment_status
        end
      end
    end
    describe "level" do
      context "should be valid when" do
        it "level is not null" do
          enrollment.level = Level.new
          enrollment.should have(0).errors_on :level
        end
      end
      context "should have error blank when" do
        it "level is null" do
          enrollment.level = nil
          enrollment.should have_error(:blank).on :level
        end
      end
    end
    describe "enrollment_number" do
      context "should be valid when" do
        it "enrollment_number is not null and is not taken" do
          enrollment.enrollment_number = "M123"
          enrollment.should have(0).errors_on :enrollment_number
        end
      end
      context "should have error blank when" do
        it "enrollment_number is null" do
          enrollment.enrollment_number = nil
          enrollment.should have_error(:blank).on :enrollment_number
        end
      end
      context "should have error taken when" do
        it "enrollment_number is already in use" do
          enrollment_number = "D123"
          FactoryGirl.create(:enrollment, :enrollment_number => enrollment_number)
          enrollment.enrollment_number = enrollment_number
          enrollment.should have_error(:taken).on :enrollment_number
        end
      end
    end
  end
  describe "Methods" do
    before(:all) do
      admission_date = YearSemester.current.semester_begin
      @delayed_enrollment = FactoryGirl.create(:enrollment, :admission_date => admission_date)
      level = @delayed_enrollment.level


      inactive_enrollment = FactoryGirl.create(:enrollment, :level => level, :admission_date => admission_date)
      FactoryGirl.create(:dismissal, :enrollment => inactive_enrollment)

      one_month_phase = FactoryGirl.create(:phase)
      FactoryGirl.create(:phase_duration, :deadline_days => 0, :deadline_months => 1, :deadline_semesters => 0, :level => level, :phase => one_month_phase)
      @two_semesters_phase = FactoryGirl.create(:phase)
      FactoryGirl.create(:phase_duration, :deadline_days => 0, :deadline_months => 0, :deadline_semesters => 2, :level => level, :phase => @two_semesters_phase)

      @enrollment_accomplished = FactoryGirl.create(:enrollment, :level => @delayed_enrollment.level, :admission_date => admission_date)
      FactoryGirl.create(:accomplishment, :enrollment => @enrollment_accomplished, :phase => one_month_phase, :conclusion_date => 1.day.ago)

      enrollment_active_deferral = FactoryGirl.create(:enrollment, :level => level, :admission_date => admission_date)
      one_semester_deferral_type = FactoryGirl.create(:deferral_type, :phase => one_month_phase, :duration_days => 0, :duration_months => 0, :duration_semesters => 1)
      FactoryGirl.create(:deferral, :enrollment => enrollment_active_deferral, :deferral_type => one_semester_deferral_type)

      @enrollment_expired_deferral = FactoryGirl.create(:enrollment, :level => level, :admission_date => (admission_date - 2.months))
      FactoryGirl.create(:deferral, :enrollment => @enrollment_expired_deferral, :deferral_type => one_semester_deferral_type)

    end

    describe "to_label" do
      it "should return the expected string" do
        enrollment_number = "M213"
        enrollment.enrollment_number = enrollment_number
        student_name = "Student"
        enrollment.student = Student.new(:name => student_name)
        enrollment.to_label.should eql("#{enrollment_number} - #{student_name}")
      end
    end
    describe "self.with_delayed_phases_on" do
      it "should return the expected enrollments" do
        result = Enrollment.with_delayed_phases_on(Date.today, nil)

        expected_result = [@delayed_enrollment.id, @enrollment_expired_deferral.id].sort
        result.sort.should eql(expected_result.sort)
      end
    end
    describe "self.with_all_phases_accomplished_on" do
      it "should return the expected enrollments" do
        FactoryGirl.create(:accomplishment, :enrollment => @enrollment_accomplished, :phase => @two_semesters_phase, :conclusion_date => 1.day.ago)
        
        result = Enrollment.with_all_phases_accomplished_on(Date.today)

        expected_result = [@enrollment_accomplished.id].sort
        result.sort.should eql(expected_result.sort)
      end
    end
  end
end